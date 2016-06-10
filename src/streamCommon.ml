(*
 * Copyright (C) 2011-2013 Citrix Inc
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published
 * by the Free Software Foundation; version 2.1 only. with the special
 * exception on linking described in file LICENSE.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *)

type protocol = Nbd | Chunked | Human | Tar | NoProtocol

let protocol_of_string = function
  | "nbd" -> Nbd | "chunked" -> Chunked | "human" -> Human
  | "tar" -> Tar | "none" -> NoProtocol
  | x -> failwith (Printf.sprintf "Unsupported protocol: %s" x)

let string_of_protocol = function
  | Nbd -> "nbd" | Chunked -> "chunked" | Human -> "human"
  | Tar -> "tar" | NoProtocol -> "none"

let supported_formats = [ "raw"; "vhd"; "hybrid" ]

let require name arg = match arg with
  | None -> failwith (Printf.sprintf "Please supply a %s argument" name)
  | Some x -> x

type t = {
  source: string;
  relative_to: string option;
  source_format: string;
  destination_format: string;
  destination: string;
  source_protocol: protocol;
  destination_protocol: protocol option;
  prezeroed: bool;
  progress: bool;
  machine: bool;
  tar_filename_prefix: string option;
  ssl_legacy: bool;
  good_ciphersuites: string option;
  legacy_ciphersuites: string option;
}

let make source relative_to source_format destination_format destination destination_fd source_protocol destination_protocol prezeroed progress machine tar_filename_prefix ssl_legacy good_ciphersuites legacy_ciphersuites =
  let source_protocol = protocol_of_string (require "source-protocol" source_protocol) in
  let destination_protocol = match destination_protocol with
    | None -> None
    | Some x -> Some (protocol_of_string x) in
  if not (List.mem source_format supported_formats)
  then failwith (Printf.sprintf "%s is not a supported format" source_format);
  if not (List.mem destination_format supported_formats)
  then failwith (Printf.sprintf "%s is not a supported format" destination_format);
  let destination = match destination_fd with
    | None -> destination
    | Some fd -> "fd://" ^ (string_of_int fd) in

  { source; relative_to; source_format; destination_format; destination; source_protocol; destination_protocol; prezeroed; progress; machine; tar_filename_prefix; ssl_legacy; good_ciphersuites; legacy_ciphersuites }

