#+begin_src asm
;;; r0: Current value.
;;; r1: Next Value.
;;; r2: Swap indicator
;;; r3: Address counter 
;;; DC: $00FF -- Array End
;;; DD: $00E0 -- Array start
;;; DE: ONE
;;; DF: ZERO
;;; E0: Start of array
;;; FF: Array end
START:
	load r2 dir $DF		; Set swap indicator to 0.
	load r3 dir $DD		; Set start pointer to $E0
ITER:			; Single address pair iteration
    load r1 idx $01		; Load indexed from pointer + 1
	cmp r1	idx $00		; Compare next to current
	bge NEXT_ADDR		; If next >= current, continue iteration
SWAP:	
	load r0 idx $00		; Load current value
	store r1 idx $00	; Store next in current
	store r0 idx $01	; Store current in next
	load r2 dir $DE		; Set swapped flag to 1
NEXT_ADDR:
	add r3 dir $DE		; PTR++
	cmp r3 dir $DC 		; PTR == $FF ?
	bne ITER		; Not finished if not equal
	cmp r2 dir $DF		; Have swapped?
	bne START		; If yes, repeat
	halt
#+end_src

** Assembler
#+begin_src haskell
  module Main where
  import Data.Char (isSpace, toLower)
  import Data.Maybe (fromMaybe)
  import Data.List.Split (wordsBy)
  import Data.Word (Word8)
  import Numeric (readBin)
  import System.IO (readFile)
  import System.Environment (getArgs)
  import Text.Printf (printf)

  main = do
    a <- getArgs
    file <- readFile . head $ a
    mapM_ print . assemble $ file

  parse :: String -> [[String]]
  parse =
    map (wordsBy (`elem` " \t,"))
    . filter (not . all isSpace)
    . map (takeWhile (/=';'))
    . lines
    . map toLower


  assemble prog = instructions
    where
      instructions = map (instruction labels) . filter (not . isLabel . head . fst) $ addresses
      labels = assignLabels addresses
      addresses = address parsed
      parsed = parse prog

  assignLabels =
    map (\(line, addr) -> (init . head $ line, addr))
    . filter (isLabel . head . fst)

  getLabel :: [(String, Word8)] -> Word8 -> String -> Word8
  getLabel dict current label = flip (-) (succ current) . fromMaybe 0 . lookup label $ dict

  address =
    zip <*> scanl (+) 0
    . map lineVal


  makeRegMode :: String -> String -> String
  makeRegMode grx m = printf "%01x" . fst . head . readBin @Word8 $ (reg grx) ++ (mode m)
  
  instruction :: [(String, Word8)] -> ([String], Word8) -> String
  instruction dict ([name, grx, m, '$':adr], n)
    = printf "%02x: %s" n $ numberOf name ++ makeRegMode grx m ++ adr

  instruction dict ([name, grx, m, label], n)
    = printf "%02x: %s" n $ numberOf name ++ makeRegMode grx m ++ printf "%02x" (getLabel dict n label)

  instruction dict ([name, '$':adr], n) = printf "%02x: %s" n $ numberOf name ++ "0" ++ adr
  instruction dict ([name, label], n) = printf "%02x: %s" n $ numberOf name ++ "0" ++ printf "%02x" (getLabel dict n label)
  instruction dict ([name], n) = printf "%02x: %s" n $ numberOf name ++ replicate 3 '0'


  isLabel = (==':') . last

  numberOf :: String -> String
  numberOf name = printf "%01x" $ case name of
    "halt" -> 0 :: Int 
    "load" -> 1
    "store" -> 2
    "add" -> 3
    "sub" -> 4
    "and" -> 5
    "lsr" -> 6
    "bne" -> 7
    "bra" -> 8
    "cmp" -> 9
    "bge" -> 10
    "beq" -> 11


  lineVal :: [String] -> Word8
  lineVal [_,_,"imm",_] = 2
  lineVal [_,_,_,_] = 1
  lineVal [_,_] = 1
  lineVal [x] = if isLabel x then 0 else 1

  reg :: String -> String
  reg = printf "%02b" . read @Int . tail


  mode x = case x of
    "dir" -> "00"
    "imm" -> "01"
    "ind" -> "10"
    "idx" -> "11"
#+end_src
