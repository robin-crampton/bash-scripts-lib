# shellcheck shell=bash
# shellcheck enable=all
# vim: ft=bash
#
# A library for Bash scripts
#
# MIT licence
#
# Copyright (c) 2009 Robin Crampton
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

[[ -n "${PROGRAM_NAME:-}" ]] \
  || PROGRAM_NAME="$(basename "$0")"
readonly PROGRAM_NAME

[[ -n "${PROGRAM_VERSION:-}" ]] \
  || PROGRAM_VERSION="1.0.0"
readonly PROGRAM_VERSION

lib::add_carriage_returns() {
  sed 's/$/\r/'
}

lib::assert_at_least_n_arguments() {
  (($# >= 2)) \
    || lib::function_error_exit "Too few arguments (expected 2, received $#)."
  (($# <= 2)) \
    || lib::function_error_exit "Too many arguments (expected 2, received $#)."
  (($1 >= $2)) \
    || lib::error_exit "Too few arguments (expected at least $2, received $1)."
}

lib::assert_date() {
  lib::function_assert_one_argument $#
  date -d "$1" &>/dev/null \
    || lib::error_exit "Invalid date: $1"
}

lib::assert_directory() {
  lib::function_assert_nonzero_arguments $#
  local directory_name
  for directory_name in "$@"; do
    lib::test_directory "${directory_name}" \
      || lib::error_exit "Not a directory: ${directory_name}"
  done
}

lib::assert_empty_directory() {
  lib::function_assert_nonzero_arguments $#
  lib::assert_directory "$@"
  local directory_name
  for directory_name in "$@"; do
    lib::test_empty_directory "${directory_name}" \
      || lib::error_exit "Not an empty directory: ${directory_name}"
  done
}

lib::assert_executable() {
  lib::function_assert_nonzero_arguments $#
  local file_name
  for file_name in "$@"; do
    lib::test_executable "${file_name}" \
      || lib::error_exit "File not executable: ${file_name}"
  done
}

lib::assert_file() {
  lib::function_assert_nonzero_arguments $#
  local file_name
  for file_name in "$@"; do
    [[ -n "${file_name:-}" ]] \
      || lib::error_exit "Missing file name."
    [[ -e "${file_name}" ]] \
      || lib::error_exit "Missing file: ${file_name}"
    [[ -f "${file_name}" ]] \
      || lib::error_exit "Not a regular file: ${file_name}"
    [[ -r "${file_name}" ]] \
      || lib::error_exit "Unreadable file: ${file_name}"
  done
}

lib::assert_file_nonblank() {
  lib::function_assert_nonzero_arguments $#
  local file_name
  for file_name in "$@"; do
    lib::assert_file_nonempty "${file_name}"
    grep --quiet '[^[:space:]]' "${file_name}" \
      || lib::error_exit "Blank file: ${file_name}"
  done
}

lib::assert_file_nonempty() {
  lib::function_assert_nonzero_arguments $#
  local file_name
  for file_name in "$@"; do
    lib::assert_file "${file_name}"
    [[ -s "${file_name}" ]] \
      || lib::error_exit "Empty file: ${file_name}"
  done
}

lib::assert_installed() {
  lib::function_assert_nonzero_arguments $#
  local dependency
  for dependency in "$@"; do
    lib::test_installed "${dependency}" \
      || lib::error_exit "Command not found: ${dependency}"
  done
}

lib::assert_length() {
  lib::function_assert_n_arguments $# 3
  if ! lib::test_length "$1" "$2"; then
    local -r length="$(printf "%'d" "${#1}")"
    local -r limit="$(printf "%'d" "$2")"
    local -r argument_name_lowercase="${3,,}"
    lib::error_exit "${argument_name_lowercase^} too long: " \
      "length is ${length}, limit is ${limit}."
  fi
}

lib::assert_n_arguments() {
  (($# >= 2)) \
    || lib::function_error_exit "Too few arguments (expected 2, received $#)."
  (($# <= 2)) \
    || lib::function_error_exit "Too many arguments (expected 2, received $#)."
  (($1 >= $2)) \
    || lib::error_exit "Too few arguments (expected $2, received $1)."
  (($1 <= $2)) \
    || lib::error_exit "Too many arguments (expected $2, received $1)."
}

lib::assert_no_arguments() {
  (($# >= 1)) \
    || lib::function_error_exit "Too few arguments (expected 1, received $#)."
  (($# <= 1)) \
    || lib::function_error_exit "Too many arguments (expected 1, received $#)."
  (($1 < 1)) \
    || lib::error_exit "Too many arguments (expected 0, received $1)."
}

lib::assert_nonzero_arguments() {
  (($# >= 1)) \
    || lib::function_error_exit "Too few arguments (expected 1, received $#)."
  (($# <= 1)) \
    || lib::function_error_exit "Too many arguments (expected 1, received $#)."
  (($1 > 0)) \
    || lib::error_exit "Too few arguments (expected 1 or more, received $#)."
}

lib::assert_one_argument() {
  (($# >= 1)) \
    || lib::function_error_exit "Too few arguments (expected 1, received $#)."
  (($# <= 1)) \
    || lib::function_error_exit "Too many arguments (expected 1, received $#)."
  (($1 >= 1)) \
    || lib::error_exit "Too few arguments (expected 1, received $1)."
  (($1 <= 1)) \
    || lib::error_exit "Too many arguments (expected 1, received $1)."
}

lib::assert_variable_is_directory() {
  lib::function_assert_nonzero_arguments $#
  local variable
  for variable in "$@"; do
    lib::assert_variable_nonempty "${variable}"
    [[ -d "${!variable}" ]] \
      || lib::error_exit \
           "Value of environment variable ${variable} is not a directory: " \
           "${!variable}"
  done
}

lib::assert_variable_nonempty() {
  lib::function_assert_nonzero_arguments $#
  local variable
  for variable in "$@"; do
    declare -p "${variable}" &>/dev/null \
      || lib::error_exit "Environment variable ${variable} is not set."
    lib::test_variable_nonempty "${variable}" \
      || lib::error_exit "Environment variable ${variable} is empty."
  done
}

lib::assert_zip_file() {
  lib::function_assert_nonzero_arguments $#
  local zip_file_name
  for zip_file_name in "$@"; do
    [[ -n "${zip_file_name:-}" ]] \
      || lib::error_exit "Missing zip file name."
    [[ "${zip_file_name}" =~ \.zip$ ]] \
      || lib::usage_error_exit "Zip file name suffix is not .zip: " \
           "${zip_file_name}"
    [[ -e "${zip_file_name}" ]] \
      || lib::error_exit "Missing zip file: ${zip_file_name}"
    [[ -f "${zip_file_name}" ]] \
      || lib::error_exit "Not a regular zip file: ${zip_file_name}"
    [[ -r "${zip_file_name}" ]] \
      || lib::error_exit "Unreadable zip file: ${zip_file_name}"
    [[ -s "${zip_file_name}" ]] \
      || lib::error_exit "Empty zip file: ${zip_file_name}"
    lib::assert_installed unzip
    lib::info "Checking zip file: ${zip_file_name}"
    unzip -tqq "${zip_file_name}" \
      || lib::error_exit "Invalid zip file: ${zip_file_name}"
  done
}

lib::compress_whitespace() {
  local set_extglob_flag
  if ! shopt -q extglob; then
    shopt -s extglob
    set_extglob_flag=1
  fi
  readonly set_extglob_flag

  local -r all_arguments="$*"
  local -r single_spaces="${all_arguments//+([[:space:]])/ }"
  local -r no_leading_space="${single_spaces# }"
  local -r no_trailing_space="${no_leading_space% }"
  lib::echo "${no_trailing_space}"

  [[ -z "${set_extglob_flag:-}" ]] \
    || shopt -u extglob
}

lib::debug() {
  lib::function_assert_nonzero_arguments $#
  lib::log debug "$@"
}

lib::duration_to_seconds() {
  lib::function_assert_one_argument $#
  local -a time_component
  IFS=":" read -ra time_component <<< "$1"
  readonly time_component
  [[ "${time_component[0]}" =~ [0-9]+ ]] \
    || lib::error_exit "Missing hours component: $1"
  local -r hours="${time_component[0]}"
  [[ "${time_component[1]}" =~ [0-9]+ ]] \
    || lib::error_exit "Missing minutes component: $1"
  local -r minutes="${time_component[1]}"
  [[ "${time_component[2]}" =~ [0-9]+\.[0-9]+ ]] \
    || lib::error_exit "Missing seconds component: $1"
  local -r seconds="${time_component[2]}"
  lib::function_assert_installed bc
  local bc
  bc="$(bc -l <<< "${hours} * 60 * 60 + ${minutes} * 60 + ${seconds}")" \
    || exit
  readonly bc
  lib::echo "${bc/#./0.}"
}

lib::echo() {
  # Adapted from https://unix.stackexchange.com/a/65819
  if (($# > 0)); then
     printf "%s" "$1"
     shift
     (($# > 0)) \
       && printf " %s" "$@"
  fi
  printf '\n'
}

lib::error() {
  lib::function_assert_nonzero_arguments $#
  lib::log error "$@"
}

lib::error_exit() {
  lib::function_assert_nonzero_arguments $#
  lib::error "$@"
  exit 1
}

lib::filename_timestamp() {
  date "+%Y-%m-%d_%H%M%S"
}

lib::format_seconds() {
  lib::function_assert_n_arguments $# 2
  local -r format="$1"
  shift
  local remaining_seconds="$1"
  shift
  lib::assert_installed bc
  local hours
  hours="$(bc <<< "${remaining_seconds} / 3600")" \
    || lib::function_error_exit "Cannot calculate hours."
  readonly hours
  remaining_seconds="$(bc <<< "${remaining_seconds} - ${hours} * 3600")" \
    || lib::function_error_exit "Cannot update remaining seconds."
  local minutes
  minutes="$(bc <<< "${remaining_seconds} / 60")" \
    || lib::function_error_exit "Cannot calculate minutes."
  readonly minutes
  remaining_seconds="$(bc <<< "${remaining_seconds} - ${minutes} * 60")" \
    || lib::function_error_exit "Cannot calculate seconds."
  readonly remaining_seconds
  # SC2059 (info): Don't use variables in the printf format string. Use
  # printf '..%s..' "$foo".
  # This is a false negative as it is the format string itself that is
  # variable.
  # shellcheck disable=SC2059
  printf "${format}\n" "${hours}" "${minutes}" "${remaining_seconds}"
}

lib::function_assert_at_least_n_arguments() {
  (($# >= 2)) \
    || lib::function_error_exit "Too few arguments (expected 2, received $#)."
  (($# <= 2)) \
    || lib::function_error_exit "Too many arguments (expected 2, received $#)."
  (($1 >= $2)) \
    || lib::error_exit "${FUNCNAME[1]}: Too few arguments " \
         "(expected at least $2, received $1)."
}

lib::function_assert_n_arguments() {
  (($# >= 2)) \
    || lib::function_error_exit "Too few arguments (expected 2, received $#)."
  (($# <= 2)) \
    || lib::function_error_exit "Too many arguments (expected 2, received $#)."
  (($1 >= $2)) \
    || lib::error_exit "${FUNCNAME[1]}: Too few arguments " \
         "(expected $2, received $1)."
  (($1 <= $2)) \
    || lib::error_exit "${FUNCNAME[1]}: Too many arguments " \
         "(expected $2, received $1)."
}

lib::function_assert_no_arguments() {
  (($# >= 1)) \
    || lib::function_error_exit "Too few arguments (expected 1, received $#)."
  (($# <= 1)) \
    || lib::function_error_exit "Too many arguments (expected 1, received $#)."
  (($1 < 1)) \
    || lib::error_exit "${FUNCNAME[1]}: Too many arguments " \
         "(expected 0, received $1)."
}

lib::function_assert_nonzero_arguments() {
  (($# >= 1)) \
    || lib::function_error_exit "Too few arguments (expected 1, received $#)."
  (($# <= 1)) \
    || lib::function_error_exit "Too many arguments (expected 1, received $#)."
  (($1 > 0)) \
    || lib::error_exit "${FUNCNAME[1]}: Too few arguments " \
         "(expected at least 1, received $1)."
}

lib::function_assert_one_argument() {
  (($# >= 1)) \
    || lib::function_error_exit "Too few arguments (expected 1, received $#)."
  (($# <= 1)) \
    || lib::function_error_exit "Too many arguments (expected 1, received $#)."
  (($1 >= 1)) \
    || lib::error_exit "${FUNCNAME[1]}: Too few arguments " \
         "(expected 1, received $1)."
  (($1 <= 1)) \
    || lib::error_exit "${FUNCNAME[1]}: Too many arguments " \
         "(expected 1, received $1)."
}

lib::function_debug() {
  lib::debug "${FUNCNAME[1]}:" "$@"
}

lib::function_error() {
  lib::error "${FUNCNAME[1]}:" "$@"
}

lib::function_error_exit() {
  lib::error_exit "${FUNCNAME[1]}:" "$@"
}

lib::function_test_at_least_n_arguments() {
  if (($# < 2)); then
    lib::function_error "Too few arguments (expected 2, received $#)."
    return 2
  fi
  if (($# > 2)); then
    lib::function_error "Too many arguments (expected 2, received $#)."
    return 2
  fi
  if (($1 < $2)); then
    lib::error "${FUNCNAME[1]}: Too few arguments " \
      "(expected at least $2, received $1)."
    return 2
  fi
}

lib::function_test_n_arguments() {
  if (($# < 2)); then
    lib::function_error "Too few arguments (expected 2, received $#)."
    return 2
  fi
  if (($# > 2)); then
    lib::function_error "Too many arguments (expected 2, received $#)."
    return 2
  fi
  if (($1 < $2)); then
    lib::error "${FUNCNAME[1]}: Too few arguments (expected $2, received $1)."
    return 2
  fi
  if (($1 > $2)); then
    lib::error "${FUNCNAME[1]}: Too many arguments (expected $2, received $1)."
    return 2
  fi
}

lib::function_test_nonzero_arguments() {
  if (($# < 1)); then
    lib::function_error "Too few arguments (expected 1, received $#)."
    return 2
  fi
  if (($# > 1)); then
    lib::function_error "Too many arguments (expected 1, received $#)."
    return 2
  fi
  if (($1 < 1)); then
    lib::error "${FUNCNAME[1]}: Too few arguments " \
      "(expected at least 1, received $1)."
    return 2
  fi
}

lib::function_test_one_argument() {
  if (($# < 1)); then
    lib::function_error "Too few arguments (expected 1, received $#)."
    return 2
  fi
  if (($# > 1)); then
    lib::function_error "Too many arguments (expected 1, received $#)."
    return 2
  fi
  if (($1 < 1)); then
    lib::error "${FUNCNAME[1]}: Too few arguments (expected 1, received $1)."
    return 2
  fi
  if (($1 > 1)); then
    lib::error "${FUNCNAME[1]}: Too many arguments (expected 1, received $1)."
    return 2
  fi
}

lib::get_options() {
  lib::function_assert_at_least_n_arguments $# 2
  local short_options
  short_options="$(lib::trim "$1")" \
    || exit
  readonly short_options
  shift
  local long_options
  long_options="$(lib::trim "$1")" \
    || exit
  readonly long_options
  shift
  local options
  options="$(POSIXLY_CORRECT=1 getopt \
    --name "${PROGRAM_NAME}" \
    --options "${short_options}" \
    --longoptions "${long_options}" \
    -- "$@" \
    )" \
    || exit
  readonly options
  lib::echo "${options}"
}

lib::hmmssxxx_to_milliseconds() {
  lib::function_assert_one_argument $#
  local -r timestamp="$1"
  shift
  [[ "${timestamp}" =~ \
^([[:digit:]]+):([[:digit:]]+):([[:digit:]]+\.[[:digit:]]{3})$ ]] \
    || lib::error_exit \
         "Expected format <hours>:<minutes>:<seconds>.<milliseconds>," \
         "received: ${timestamp}"
  local -r hours="$((10#${BASH_REMATCH[1]}))"
  local -r minutes="$((10#${BASH_REMATCH[2]}))"
  ((minutes < 60)) \
    || lib::error_exit "Minutes component out of range: ${minutes}"
  local -r seconds="${BASH_REMATCH[3]}"
  local -r whole_seconds="$((10#${seconds%.*}))"
  ((whole_seconds < 60)) \
    || lib::error_exit "Seconds component out of range: ${seconds}"
  local -r milliseconds="$((10#${seconds#*.}))"
  lib::echo $(((hours * 3600 + minutes * 60 + whole_seconds) * 1000 + milliseconds))
}

lib::info() {
  lib::function_assert_nonzero_arguments $#
  lib::log info "$@"
}

lib::load_id_array() {
  lib::function_assert_at_least_n_arguments $# 2
  local -n id_array_reference="$1"
  shift
  local -r id_type_name_lowercase="${1,,}"
  shift
  [[ -n "${id_type_name_lowercase:-}" ]] \
    || lib::function_error_exit "Missing id type."
  id_array_reference=()
  local -A id_associative_array
  local id
  for id in "$@"; do
    id="$(lib::trim "${id}")" \
      || exit
    [[ -n "${id:-}" ]] \
      || lib::error_exit "Empty ${id_type_name_lowercase} id found."
    lib::test_nonnegative_integer "${id}" \
      || lib::error_exit "${id_type_name_lowercase^} " \
           "id is not a natural number: ${id}"
    [[ -z "${id_associative_array[${id}]:-}" ]] \
      || lib::error_exit "Duplicate ${id_type_name_lowercase} id: ${id}"
    id_associative_array["${id}"]=1
    id_array_reference+=("${id}")
  done
}

lib::log() {
  lib::function_assert_at_least_n_arguments $# 2
  local -r message_log_level="$1"
  shift
  [[ -n "${message_log_level:-}" ]] \
    || lib::error_exit "Missing message log level."
  local -r message_log_level_lowercase="${message_log_level,,}"
  case "${message_log_level_lowercase}" in
    all|trace|debug|info|warn|error)
      ;;
    *)
      lib::error_exit "Invalid message log level: ${message_log_level}"
  esac
  local current_log_level_lowercase
  current_log_level_lowercase="$(lib::verbosity_to_log_level)" \
    || exit
  readonly current_log_level_lowercase
  case "${message_log_level_lowercase}-${current_log_level_lowercase}" in
    all-all)
      ;;
    trace-trace|trace-all)
      ;;
    debug-debug|debug-trace|debug-all)
      ;;
    info-info|info-debug|info-trace|info-all)
      ;;
    warn-warn|warn-info|warn-debug|warn-trace|warn-all)
      ;;
    error-error|error-warn|error-info|error-debug|error-trace|error-all)
      ;;
    *)
      return
  esac
  if [[ "${BASH_SCRIPTS_LIB_LOG_STYLE:-}" =~ logfile ]]; then
    local timestamp
    timestamp="$(date "+%Y-%m-%d %H:%M:%S.%3N")" \
      || exit
    readonly timestamp
    case "${message_log_level_lowercase}" in
      info)
        printf "${timestamp} %-5s ${PROGRAM_NAME}: $*\\n" \
          "${message_log_level_lowercase^^}"
        ;;
      *)
        printf "${timestamp} %-5s ${PROGRAM_NAME}: $*\\n" \
          "${message_log_level_lowercase^^}" >&2
    esac
  else
    case "${message_log_level_lowercase}" in
      info)
        lib::echo "${PROGRAM_NAME}: ${message_log_level_lowercase}: $*"
        ;;
      warn)
        lib::echo "${PROGRAM_NAME}: WARNING: $*" >&2
        ;;
      *)
        lib::echo "${PROGRAM_NAME}: ${message_log_level_lowercase^^}: $*" >&2
    esac
  fi
}

lib::milliseconds_to_hmmssxxx() {
  lib::function_test_one_argument $# \
    || return
  local -r total_milliseconds="$1"
  shift
  lib::test_nonnegative_integer "${total_milliseconds}" \
    || return
  local -r hours=$((total_milliseconds / 3600000))
  local -r minutes=$(((total_milliseconds % 3600000) / 60000))
  local -r seconds=$(((total_milliseconds % 60000) / 1000))
  local -r milliseconds=$((total_milliseconds % 1000))
  printf "%d:%02d:%02d.%03d\n" "${hours}" "${minutes}" "${seconds}" "${milliseconds}"
}

lib::osql() {
  lib::function_test_nonzero_arguments $# \
    && lib::osqlplus "$@"
}

lib::osql_escape() {
  lib::function_assert_one_argument $#
  lib::echo "${1//\'/\'\'}"
}

lib::osql_escape_multiline() {
  lib::function_assert_at_least_n_arguments 2 $#
  local -r indent_spaces_count="$1"
  shift
  lib::test_nonnegative_integer "${indent_spaces_count}" \
    || lib::error_exit "Indent spaces count is not a natural number: " \
         "${indent_spaces_count}"
  local -r indent_spaces="$(printf "%${indent_spaces_count}s")"
  printf "''\n"
  sed \
    -e "s/'/''/g" -e "s/^/${indent_spaces}|| '/" \
    -e "s/\$/' || CHR(10)/" \
    <<< "$1"
}

lib::osql_escaped_or_clause() {
  lib::function_assert_at_least_n_arguments $# 1
  local column_name="$1"
  shift
  local argument
  local or_clause
  for argument in "$@"; do
    if [[ -z "${or_clause:-}" ]]; then
      or_clause="${column_name} = '""${argument//\'/\'\'}""'"
    else
      # Include a newline to avoid "SP2-0027: Input is too long", an
      # Oracle SQL*Plus limitation.
      or_clause+="
         OR ${column_name} = ""'""${argument//\'/\'\'}""'"
    fi
  done
  lib::echo "${or_clause}"
}

lib::osql_to_csv() {
  lib::function_test_nonzero_arguments $# \
    && lib::osqlplus -M "CSV ON QUOTE OFF" "$@"
}

lib::osql_to_quoted_csv() {
  lib::function_test_nonzero_arguments $# \
    && lib::osqlplus -M "CSV ON QUOTE ON" "$@"
}

lib::osqlplus() {
  # The output of this function is likely to be read via process
  # substitution, so return an error code rather than exiting the
  # subshell.
  lib::function_test_nonzero_arguments $# \
    || return
  if ! lib::test_installed sqlplus; then
    lib::error "Command not found: sqlplus"
    return 1
  fi
  if ! lib::test_osql_connection "$@"; then
    lib::error "Cannot connect to the database."
    return 1
  fi
  local input
  if ! input="$(</dev/stdin)"; then
    lib::error "Cannot read standard input."
    return 1
  fi
  input="
SET HEADING OFF
SET FEEDBACK OFF
SET LONG 999999999
${input}
"
  local -r nls_lang="${NLS_LANG:-}"
  export NLS_LANG=".AL32UTF8"
  local output
  local sqlplus_error
  output="$(sqlplus -S "$@" <<< "${input}")" \
    || sqlplus_error=1
  if [[ -n "${nls_lang:-}" ]]; then
    NLS_LANG="${nls_lang}"
  else
    unset NLS_LANG
  fi
  if [[ -n "${sqlplus_error:-}" ]]; then
    lib::error "Cannot run the SQL."
    return 1
  fi
  output="$(tr -d '\r' <<< "${output}")" \
    || return 1
  # Print the output, deleting the last line if it's blank.
  sed '${/./!d}' <<< "${output}" \
    || true
}

lib::plural() {
  lib::function_assert_n_arguments $# 2
  if (($2 == 1)); then
    lib::echo "$1"
  else
    lib::echo "$1s"
  fi
}

lib::remove_carriage_returns() {
  tr -d '\r'
}

lib::remove_first_open_p_and_last_close_p_tags() {
  lib::function_assert_one_argument $#
  sed --null-data -e 's/^\s*<p>\s*//' -e 's/\s*<\/p>\s*$//' <<< "$1"
}

lib::replace_newlines_with_spaces() {
  # https://www.gnu.org/software/bash/manual/html_node/ANSI_002dC-Quoting.html
  local -r without_carriage_returns="${1//[$'\r']}"
  lib::echo "${without_carriage_returns//[$'\n']/ }"
}

lib::seconds_to_hhmmssxxx() {
  lib::function_assert_one_argument $#
  lib::format_seconds "%02d:%02d:%06.3f" "$1"
}

lib::seconds_to_hours_mmssxxx() {
  lib::function_assert_one_argument $#
  lib::format_seconds "%d:%02d:%06.3f" "$1"
}

lib::set_variable_from_heredoc() {
  local -n variable="$1"
  read -r -d "" variable
}

lib::test_directory() {
  lib::function_test_nonzero_arguments $# \
    || return
  local directory_name
  local fail_flag
  for directory_name in "$@"; do
    if [[ ! -d "${directory_name}" ]]; then
      lib::function_debug "Not a directory: ${directory_name}"
      fail_flag=1
      break
    fi
  done
  [[ -z "${fail_flag:-}" ]]
}

lib::test_email_address() {
  lib::function_test_one_argument $# \
    || return
  # https://en.wikipedia.org/wiki/Email_address#Syntax
  if [[ ! "$1" =~ ^[^@]{1,64}@([[:alnum:]-]{1,63}.)+[[:alnum:]-]{1,63}$ ]]; then
    lib::function_debug "Invalid email address: $1"
    return 1
  fi
}

lib::test_empty_directory() {
  lib::function_test_nonzero_arguments $# \
    || return
  lib::test_directory "$@" \
    || return
  local directory_name
  local find_empty_directory
  local fail_flag
  for directory_name in "$@"; do
    if ! find_empty_directory=\
"$(find "${directory_name}" -maxdepth 0 -type d -empty)"; then
      lib::function_debug "Not an empty directory: ${directory_name}"
      fail_flag=1
      break
    elif [[ -z "${find_empty_directory:-}" ]]; then
      lib::function_debug "Not an empty directory: ${directory_name}"
      fail_flag=1
      break
    fi
  done
  [[ -z "${fail_flag:-}" ]]
}

lib::test_executable() {
  lib::function_test_nonzero_arguments $# \
    || return
  local file_name
  local fail_flag
  for file_name in "$@"; do
    if [[ ! -x "${file_name}" ]]; then
      lib::function_debug "File not executable: ${file_name}"
      fail_flag=1
      break
    fi
  done
  [[ -z "${fail_flag:-}" ]]
}

lib::test_installed() {
  lib::function_test_nonzero_arguments $# \
    || return
  local dependency
  local fail_flag
  for dependency in "$@"; do
    if ! hash "${dependency}" 2>/dev/null; then
      lib::function_debug "Command not found: ${dependency}"
      fail_flag=1
      break
    fi
  done
  [[ -z "${fail_flag:-}" ]]
}

lib::test_iso_calendar_date() {
  lib::function_test_one_argument $# \
    || return
  # https://en.wikipedia.org/wiki/ISO_8601#Calendar_dates
  if [[ ! "$1" =~ ^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}$ \
        && ! "$1" =~ ^[[:digit:]]{4}[[:digit:]]{2}[[:digit:]]{2}$ ]]; then
    lib::function_debug "Invalid ISO-8601 calendar date format: $1"
    return 1
  fi
  if ! date --date="$1" &>/dev/null; then
    lib::function_debug "Invalid ISO-8601 calendar date: $1"
    return 1
  fi
}

lib::test_iso_date_time_basic() {
  lib::function_test_one_argument $# \
    || return
  # https://en.wikipedia.org/wiki/ISO_8601#Combined_date_and_time_representations
  if [[ ! "$1" =~ \
^[[:digit:]]{4}[[:digit:]]{2}[[:digit:]]{2}T[[:digit:]]{2}[[:digit:]]{2}$ \
      ]]; then
    lib::function_debug \
      "Invalid ISO-8601 basic combined date and time format: $1"
    return 1
  fi
  if ! date --date="$1" &>/dev/null; then
    lib::function_debug "Invalid ISO-8601 basic combined date and time: $1"
    return 1
  fi
}

lib::test_iso_date_time_extended() {
  lib::function_test_one_argument $# \
    || return
  # https://en.wikipedia.org/wiki/ISO_8601#Combined_date_and_time_representations
  if [[ ! "$1" =~ \
^[[:digit:]]{4}-[[:digit:]]{2}-[[:digit:]]{2}T[[:digit:]]{2}:[[:digit:]]{2}$ \
      ]]; then
    lib::function_debug \
      "Invalid ISO-8601 extended combined date and time format: $1"
    return 1
  fi
  if ! date --date="$1" &>/dev/null; then
    lib::function_debug "Invalid ISO-8601 extended combined date and time: $1"
    return 1
  fi
}

lib::test_iso_extended_time_hhmm() {
  lib::function_test_one_argument $# \
    || return
  # https://en.wikipedia.org/wiki/ISO_8601#Times
  if ! [[ "$1" =~ ^[[:digit:]]{2}:[[:digit:]]{2}$ ]]; then
    lib::function_debug "Invalid ISO-8601 extended time format: $1"
    return 1
  fi
  if ! date --date="1970-01-01 $1" &>/dev/null; then
    lib::function_debug "Invalid ISO-8601 extended time: $1"
    return 1
  fi
}

lib::test_length() {
  lib::function_test_n_arguments $# 2 \
    || return
  if [[ ! "$2" =~ ^[[:digit:]]+$ ]]; then
    lib::function_error "Invalid length: $2"
    return 2
  fi
  ((${#1} <= $2))
}

lib::test_nonnegative_integer() {
  lib::function_test_one_argument $# \
    || return
  [[ "$1" =~ ^[[:digit:]]+$ ]]
}

lib::test_osql_connection() {
  lib::function_test_nonzero_arguments $# \
    || return
  lib::test_installed sqlplus \
    || return
  local -r nls_lang="${NLS_LANG:-}"
  export NLS_LANG=".AL32UTF8"
  local output
  local sqlplus_error
  output="$(sqlplus -S "$@" <<!
SET HEADING OFF
SET FEEDBACK OFF
SELECT 'deadc0de' FROM dual;
!
    )" \
    || sqlplus_error=1
  if [[ -n "${nls_lang:-}" ]]; then
    NLS_LANG="${nls_lang}"
  else
    unset NLS_LANG
  fi
  if [[ -n "${sqlplus_error:-}" ]]; then
    lib::function_debug "Cannot connect to the database."
    return 1
  fi
  if ! grep --fixed-strings --quiet "deadc0de" <<< "${output}"; then
    lib::function_debug "Cannot query the database."
    return 1
  fi
}

lib::test_real_nonnegative_number() {
  lib::function_test_one_argument $# \
    || return
  [[ "$1" =~ ^[[:digit:]]+(\.[[:digit:]]+)?$ ]]
}

lib::test_variable_nonempty() {
  lib::function_test_one_argument $# \
    || return
  [[ -n "${!1:-}" ]]
}

lib::to_csv() {
  local csv
  local i
  for i in "$@"; do
    if [[ -z "${csv:-}" ]]; then
      csv="${i}"
    else
      csv+=", ${i}"
    fi
  done
  lib::echo "${csv}"
}

lib::to_csv_from_lines() {
  # Skip blank lines and comments.
  local line
  local csv
  while IFS= read -r line; do
    line="$(lib::trim "${line}")" \
      || exit
    [[ -n "${line:-}" && "${line:0:1}" != "#" ]] \
      || continue
    if [[ -z "${csv:-}" ]]; then
      csv="${line}"
    else
      csv+=", ${line}"
    fi
  done
  lib::echo "${csv}"
}

lib::to_osql_escaped_csv() {
  local i
  local csv
  for i in "$@"; do
    if [[ -z "${csv:-}" ]]; then
      csv="'""${i//\'/\'\'}""'"
    else
      csv+=", ""'""${i//\'/\'\'}""'"
    fi
  done
  lib::echo "${csv}"
}

lib::to_osql_escaped_csv_from_lines() {
  # Skip blank lines and comments.
  local line
  local csv
  while IFS= read -r line; do
    line="$(lib::trim "${line}")" \
      || exit
    [[ -n "${line:-}" && "${line:0:1}" != "#" ]] \
      || continue
    if [[ -z "${csv:-}" ]]; then
      csv="'""${line//\'/\'\'}""'"
    else
      csv+=", ""'""${line//\'/\'\'}""'"
    fi
  done
  lib::echo "${csv}"
}

lib::trace() {
  lib::function_assert_nonzero_arguments $#
  lib::log trace "$@"
}

lib::trim() {
  local set_extglob_flag
  if ! shopt -q extglob; then
    shopt -s extglob
    set_extglob_flag=1
  fi
  readonly set_extglob_flag

  local -r all_arguments="$*"
  local -r no_leading_spaces="${all_arguments##+([[:space:]])}"
  local -r no_trailing_spaces="${no_leading_spaces%%+([[:space:]])}"
  lib::echo "${no_trailing_spaces}"

  [[ -z "${set_extglob_flag:-}" ]] \
    || shopt -u extglob
}

# SC2120 (warning): lib::usage_error_exit references arguments, but none
# are ever passed.
# shellcheck disable=SC2120
lib::usage_error_exit() {
  (($# < 1)) \
    || lib::error "$@"
  lib::echo "Try ${PROGRAM_NAME} --help for more information." >&2
  exit 2
}

lib::usage_error_help_exit() {
  lib::function_assert_nonzero_arguments $#
  lib::error "$1"
  shift
  if [[ -n "${1:-}" ]]; then
    lib::echo "$@" >&2
  else
    lib::echo "Try ${PROGRAM_NAME} --help for more information." >&2
  fi
  exit 2
}

lib::usage_help_exit() {
  lib::function_assert_nonzero_arguments $#
  lib::echo "$@"
  exit 0
}

lib::verbosity_to_log_level() {
  local verbosity_level="${VERBOSITY:-0}"
  lib::test_nonnegative_integer "${verbosity_level}" \
    || verbosity_level=0
  if ((verbosity_level <= 0)); then
    lib::echo "warn"
  elif ((verbosity_level == 1)); then
    lib::echo "info"
  elif ((verbosity_level == 2)); then
    lib::echo "debug"
  elif ((verbosity_level == 3)); then
    lib::echo "trace"
  else
    lib::echo "all"
  fi
}

lib::version_exit() {
  if [[ -n "${PROGRAM_PACKAGE:-}" ]]; then
    lib::echo "${PROGRAM_NAME} (${PROGRAM_PACKAGE:?}) ${PROGRAM_VERSION}"
  else
    lib::echo "${PROGRAM_NAME} ${PROGRAM_VERSION}"
  fi
  [[ -z "${PROGRAM_ATTRIBUTION:-}" ]] \
    || lib::echo "${PROGRAM_ATTRIBUTION:?}"
  exit 0
}

lib::warn() {
  lib::function_assert_nonzero_arguments $#
  lib::log warn "$@"
}
