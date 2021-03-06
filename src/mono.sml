(* Copyright (c) 2008-2010, 2013-2014, Adam Chlipala
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * - The names of contributors may not be used to endorse or promote products
 *   derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *)

structure Mono = struct

type 'a located = 'a ErrorMsg.located

datatype datatype_kind = datatype DatatypeKind.datatype_kind

datatype typ' =
         TFun of typ * typ
       | TRecord of (string * typ) list
       | TDatatype of int * (datatype_kind * (string * int * typ option) list) ref
       | TFfi of string * string
       | TOption of typ
       | TList of typ
       | TSource
       | TSignal of typ

withtype typ = typ' located

datatype patCon =
         PConVar of int (* constructor identifier *)
       | PConFfi of {mod : string, datatyp : string, con : string, arg : typ option}

datatype pat' =
         PVar of string * typ
       | PPrim of Prim.t
       | PCon of datatype_kind * patCon * pat option
       | PRecord of (string * pat * typ) list
       | PNone of typ
       | PSome of typ * pat

withtype pat = pat' located

datatype javascript_mode =
         Attribute
       | Script
       | Source of typ

datatype effect = datatype Export.effect
datatype export_kind = datatype Export.export_kind

datatype failure_mode = datatype Settings.failure_mode

datatype binop_intness = Int | NotInt

datatype exp' =
         EPrim of Prim.t
       | ERel of int   (* deBruijn index *)
       | ENamed of int (* named variable *)
       | ECon of datatype_kind * patCon * exp option
       | ENone of typ
       | ESome of typ * exp
       | EFfi of string * string
       | EFfiApp of string * string * (exp * typ) list
       | EApp of exp * exp
       | EAbs of string * typ * typ * exp

       | EUnop of string * exp
       | EBinop of binop_intness * string * exp * exp

       | ERecord of (string * exp * typ) list
       | EField of exp * string

       | ECase of exp * (pat * exp) list * { disc : typ, result : typ }

       | EStrcat of exp * exp

       | EError of exp * typ
       | EReturnBlob of {blob : exp option, mimeType : exp, t : typ}
       | ERedirect of exp * typ

       | EWrite of exp
       | ESeq of exp * exp
       | ELet of string * typ * exp * exp

       | EClosure of int * exp list

       | EQuery of { exps : (string * typ) list, (* name of computed field, type of field*)
                     tables : (string * (string * typ) list) list,
                     state : typ,
                     query : exp, (* exp of string type containing sql query *)
                     body : exp,
                     initial : exp }
       | EDml of exp * failure_mode
       | ENextval of exp
       | ESetval of exp * exp

       | EUnurlify of exp * typ * bool

       | EJavaScript of javascript_mode * exp

       | ESignalReturn of exp
       | ESignalBind of exp * exp
       | ESignalSource of exp

       | EServerCall of exp * typ * effect * failure_mode
       | ERecv of exp * typ
       | ESleep of exp
       | ESpawn of exp

withtype exp = exp' located

datatype policy =
         PolClient of exp
       | PolInsert of exp
       | PolDelete of exp
       | PolUpdate of exp
       | PolSequence of exp

datatype decl' =
         DDatatype of (string * int * (string * int * typ option) list) list
       | DVal of string * int * typ * exp * string
       | DValRec of (string * int * typ * exp * string) list
       | DExport of export_kind * string * int * typ list * typ * bool

       | DTable of string * (string * typ) list * exp * exp
       | DSequence of string
       | DView of string * (string * typ) list * exp
       | DDatabase of {name : string, expunge : int, initialize : int}

       | DJavaScript of string

       | DCookie of string
       | DStyle of string

       | DTask of exp * exp

       | DPolicy of policy
       | DOnError of int

withtype decl = decl' located

datatype sidedness =
         ServerOnly
       | ServerAndPull
       | ServerAndPullAndPush

datatype dbmode =
         NoDb
       | OneQuery
       | AnyDb

type file = decl list * (int * sidedness * dbmode) list

end
