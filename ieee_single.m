#! /usr/bin/octave -qf

# MAC0210 - Laboratório de Métodos Numéricos - 2017/1
# Exercicio Programa I - IEEE Single Representation
# Renan Fichberg - 7991131
# Professor: Ernesto G. Birgin
# Monitor: Lucas Magno

function main()
  printf("\nSimple IEEE Single Representation program. Usage information can be found in the documentation.\n\n")

  while true
    a = scan_keyboard("Input value for A:\n>> ");
    [a_value_bstring, a_sign_bstring] = input_to_number(a);
    a_ieee_bstring = number_to_ieee_single(a_value_bstring, a_sign_bstring);
    printf("A = "); print_word(a_ieee_bstring);

    b = scan_keyboard("Input value for B:\n>> ");
    [b_value_bstring, b_sign_bstring] = input_to_number(b);
    b_ieee_bstring = number_to_ieee_single(b_value_bstring, b_sign_bstring);
    printf("B = "); print_word(b_ieee_bstring);

    op = scan_keyboard("Select an operation (+ or -):\n>> ");
    r_ieee_string = operate(op, a_ieee_bstring, b_ieee_bstring);
    printf("R = "); print_word(r_ieee_string);
  endwhile
endfunction

# Shifts significant string of ieee string by 'positions' positions and update exponent
function ieee_bstring = shift_right_ieee_string(ieee_string, positions, exponent)
  # Update exponent binary string
  exponent_bstring = dec2bin(exponent);
  while length(exponent_bstring) < 8
    exponent_bstring = strcat("0", exponent_bstring);
  endwhile

  # Update significant binary string performing right shitf operation
  significant_bstring = substr(ieee_string, 10);
  count = 0;
  while count < positions
    significant_bstring = strcat("0", significant_bstring);
    count++;
  endwhile
  significant_bstring = substr(significant_bstring, 1, 24);

  ieee_bstring = strcat(ieee_string(1), strcat(exponent_bstring, significant_bstring));
endfunction

# Perform subtraction operation between greater and smaller binary IEEE strings
function r_ieee_bstring = perform_addition(g_ieee_bstring, s_ieee_bstring)
  r_significant_bstring = "";
  g_significant_bstring = substr(g_ieee_bstring, 10);
  s_significant_bstring = substr(s_ieee_bstring, 10);

  bit = length(a_significant_bstring);
  while bit > 0
    if a_significant_bstring(bit) == '1' && b_significant_bstring(bit) == '1'

      #r_significant_bstring = strcat("0", r_significant_bstring);

    elseif (a_significant_bstring(bit) == '1' && b_significant_bstring(bit) == '0') || (a_significant_bstring(bit) == '0' && b_significant_bstring(bit) == '1')

    else # a_ieee_bstring(bit) == '0' && b_ieee_bstring(bit) == '0'

    endif
    bit--;
  endwhile

  #if carry == 1
  #  r_significant_bstring = strcat("1", r_significant_bstring);
  #endif

  r_ieee_bstring = strcat(a_ieee_bstring(1), strcat(substr(a_ieee_bstring, 2, 8), r_significant_bstring));
endfunction

# Perform addition operation between A and B binary IEEE strings
function r_ieee_bstring = perform_addition(a_ieee_bstring, b_ieee_bstring)
  r_significant_bstring = "";
  a_significant_bstring = substr(a_ieee_bstring, 10);
  b_significant_bstring = substr(b_ieee_bstring, 10);

  carry = 0;
  bit = length(a_significant_bstring);
  while bit > 0
    if a_significant_bstring(bit) == '1' && b_significant_bstring(bit) == '1'
      if carry == 0
        r_significant_bstring = strcat("0", r_significant_bstring);
      else # carry == 1
        r_significant_bstring = strcat("1", r_significant_bstring);
      endif
      carry = 1;
    elseif (a_significant_bstring(bit) == '1' && b_significant_bstring(bit) == '0') || (a_significant_bstring(bit) == '0' && b_significant_bstring(bit) == '1')
      if carry == 0
        r_significant_bstring = strcat("1", r_significant_bstring);
        carry = 0;
      else # carry == 1
        r_significant_bstring = strcat("0", r_significant_bstring);
        carry = 1;
      endif
    else # a_ieee_bstring(bit) == '0' && b_ieee_bstring(bit) == '0'
      if carry == 0
        r_significant_bstring = strcat("0", r_significant_bstring);
      else # carry == 1
        r_significant_bstring = strcat("1", r_significant_bstring);
      endif
      carry = 0;
    endif
    bit--;
  endwhile

  if carry == 1
    r_significant_bstring = strcat("1", r_significant_bstring);
  endif

  r_ieee_bstring = strcat(a_ieee_bstring(1), strcat(substr(a_ieee_bstring, 2, 8), r_significant_bstring));
endfunction

# Normalize significant string and exponent of resulting IEEE binary string
function r_ieee_bstring = normalize_ieee_bstring(r_ieee_bstring)
  significant_bstring = substr(r_ieee_bstring, 10);

  positions = 0;
  if length(significant_bstring) > 24 # Answer >= 2. Need to normalize. Carry was preppended
    positions = length(significant_bstring) - 24;
    new_exponent = bin2dec(substr(r_ieee_bstring, 2, 8)) + positions;
    exponent_bstring = dec2bin(new_exponent);
    while length(exponent_bstring) < 8
      exponent_bstring = strcat("0", exponent_bstring);
    endwhile
    significant_bstring = substr(significant_bstring, 1);
  elseif significant_bstring(1) == '0' # Answer < 1. Need to normalize.
    occ = strchr(significant_bstring, "1");
    position = occ(1) - 1;
    new_exponent = bin2dec(substr(r_ieee_bstring, 2, 8)) - position;
    while length(exponent_bstring) < 8
      exponent_bstring = strcat("0", exponent_bstring);
    endwhile
    # TODO: MUST APPEND GUARDBITS AT THE END TOO!
    significant_bstring = substr(significant_bstring, position);
  else
    # It might never enter this condition...
    printf("Normalization error. Unexpected case. Terminating execution.");
    exit;
  endif

  r_ieee_bstring = strcat(r_ieee_bstring(1), strcat(exponent_bstring, significant_bstring));
endfunction

# Perform addition operation of + A + B or - A - B
function r_ieee_bstring = ieee_addition(a_ieee_bstring, b_ieee_bstring)
  # Recover exponents
  exponent_a = bin2dec(substr(a_ieee_bstring, 2, 8));
  exponent_b = bin2dec(substr(b_ieee_bstring, 2, 8));

  # Preppend hidden bit
  a_ieee_bstring = strcat(substr(a_ieee_bstring, 1, 9), strcat("1", substr(a_ieee_bstring, 10)));
  b_ieee_bstring = strcat(substr(b_ieee_bstring, 1, 9), strcat("1", substr(b_ieee_bstring, 10)));

  # Allign exponents and arrange significant (remain unchanged if they are equal)
  if exponent_a != exponent_b
    if exponent_a > exponent_b
      b_ieee_bstring = shift_right_ieee_string(b_ieee_bstring, exponent_a - exponent_b, exponent_a);
    elseif exponent_a < exponent_b
      a_ieee_bstring = shift_right_ieee_string(a_ieee_bstring, exponent_b - exponent_a, exponent_b);
    endif
  endif

  # Add numbers. Sign of the answer is the same of the numbers
  r_ieee_bstring = perform_addition(a_ieee_bstring, b_ieee_bstring);

  # Normalize if answer >= 2 or answer < 1
  r_ieee_bstring = normalize_ieee_bstring(r_ieee_bstring);

  # Remove hidden bit
  r_ieee_bstring = strcat(r_ieee_bstring(1), strcat(substr(r_ieee_bstring, 2, 8), substr(r_ieee_bstring, 11)));
endfunction

# Perform subtraction operation of + A - B or + B - A
function r_ieee_bstring = ieee_subtraction(a_ieee_bstring, b_ieee_bstring)
  # Recover exponents
  exponent_a = bin2dec(substr(a_ieee_bstring, 2, 8));
  exponent_b = bin2dec(substr(b_ieee_bstring, 2, 8));

  # Preppend hidden bit
  a_ieee_bstring = strcat(substr(a_ieee_bstring, 1, 9), strcat("1", substr(a_ieee_bstring, 10)));
  b_ieee_bstring = strcat(substr(b_ieee_bstring, 1, 9), strcat("1", substr(b_ieee_bstring, 10)));

  # Allign exponents (remain unchanged if they are equal)
  if exponent_a != exponent_b
    if exponent_a > exponent_b
      b_ieee_bstring = shift_right_ieee_string(b_ieee_bstring, exponent_a - exponent_b, exponent_a);
    elseif exponent_a < exponent_b
      a_ieee_bstring = shift_right_ieee_string(a_ieee_bstring, exponent_b - exponent_a, exponent_b);
    endif
  endif

  # Define which number is greater (A > B or B > A)
  significant_a = bin2dec(substr(a_ieee_bstring, 10));
  significant_b = bin2dec(substr(b_ieee_bstring, 10));

  # Subtract the smaller from the greater (+ A - B or + B - A).
  # Keep sign of the greater number in answer
  if significant_a >= significant_b
    r_ieee_bstring = perform_subtraction(a_ieee_bstring, b_ieee_bstring);
  else
    r_ieee_bstring = perform_subtraction(b_ieee_bstring, a_ieee_bstring);
  endif

  # Normalize if answer >= 2 or answer < 1
  r_ieee_bstring = normalize_ieee_bstring(r_ieee_bstring);

  # Remove hidden bit
  r_ieee_bstring = strcat(r_ieee_bstring(1), strcat(substr(r_ieee_bstring, 2, 8), substr(r_ieee_bstring, 11)));
endfunction

function r_ieee_bstring = operate(op, a_ieee_bstring, b_ieee_bstring);
  if length(op) > 1 || (op(1) != '-' && op(1) != '+')
    printf("Invalid operand input. Was expecting '+' or '-'. Terminating execution.");
    exit;
  else
    # Invert number sign
    if op(1) == '-'
      if b_ieee_bstring(1) == '0'
        b_ieee_bstring(1) = '1';
      else
        b_ieee_bstring(1) = '0';
      endif
    endif

    # Perform operation A op B
    if b_ieee_bstring(1) == a_ieee_bstring(1)
      r_ieee_bstring = ieee_addition(a_ieee_bstring, b_ieee_bstring);
    else
      #r_ieee_bstring = ieee_subtraction(a_ieee_bstring, b_ieee_bstring);
      exit;
    endif
  endif
endfunction

# Converts number to IEEE Single Format
function ieee_string = number_to_ieee_single(number_bstring, sign_bstring)
  occ = strchr(number_bstring, '.');
  # Integer number. Max allowed: 340282366920938463463374607431768211455
  if length(occ) == 0
    dec_bstring = number_bstring;
    frac_bstring = "";
  # Floating point number.
  else
    dec_bstring = substr(number_bstring, 1, occ - 1);
    frac_bstring = substr(number_bstring, occ + 1);
  endif

  ieee_string = build_iee_single_representation(dec_bstring, frac_bstring, sign_bstring);
endfunction

# Constructs string representing the number in IEEE Single Format
function ieee_string = build_iee_single_representation(dec_bstring, frac_bstring, sign_bstring)
  # Our number N is: |N| < 1 ------> exponent < 0
  if dec_bstring(1) == "0" && length(dec_bstring) == 1
    exponent = first_occurence_of_bit_1(frac_bstring);
    if ((-1) * exponent) < -126
      # minimum input tested acceptec = 0.000000000000000000000000000000000000012
      printf("Received number doesn't fit the normalized interval (exponent < -126 = exp_min). Terminanting execution.");
      exit;
    endif
    frac_bstring = hide_ho_bit_fractional(frac_bstring, exponent);
    significant_bstring = build_significant_bstring("", frac_bstring);
    exponent_bstring = build_exponent_bstring(exponent * (-1));
    ieee_string = strcat(sign_bstring, strcat(exponent_bstring, significant_bstring));
  # Our number N is: |N| >= 1 -----> exponent >= 0
  else
    dec_bstring = hide_ho_bit_decimal(dec_bstring);
    exponent = length(dec_bstring);
    if exponent > 127
      printf("Received number doesn't fit the normalized interval (exponent > 127 = exp_max). Terminanting execution.");
      exit;
    endif
    significant_bstring = build_significant_bstring(dec_bstring, frac_bstring);
    exponent_bstring = build_exponent_bstring(exponent);
    ieee_string = strcat(sign_bstring, strcat(exponent_bstring, significant_bstring));
  endif
endfunction

# Locates the first occurence of the digit 1 in a fracional binary string and returns its index
function occ = first_occurence_of_bit_1(bstring)
  try
    occ = strchr(bstring, '1');
    occ = occ(1);
  catch
    occ = 127;
  end_try_catch
endfunction

# Build exponent binary string of size 8. Exponent string is a biased representation, as we
# store the representation of the number '127 + exponent'
function exponent_bstring = build_exponent_bstring(exponent)
  exponent_bstring = dec2bin(exponent + 127);
  while length(exponent_bstring) < 8
    exponent_bstring = strcat("0", exponent_bstring);
  endwhile
endfunction

# Builds significant binary string concatenating both decimal and fractional binary strings
# and then truncating it, keeping just the 23 left-most bits.
function significant_bstring = build_significant_bstring(dec_bstring, frac_bstring)
  significant_bstring = strcat(dec_bstring, frac_bstring);
  # Retain guard bits
  if length(significant_bstring) >= 23
    if length(significant_bstring) >= 25
      significant_bstring = substr(significant_bstring, 1, 25);
    else
      significant_bstring = substr(significant_bstring, 1, length(significant_bstring));
    endif
  else
    if length(significant_bstring) > 0
      significant_bstring = substr(significant_bstring, 1, length(significant_bstring));
    endif
  endif
  # Significant binary string with 2 Guard bits
  while length(significant_bstring) < 25
    significant_bstring = strcat(significant_bstring, "0");
  endwhile
endfunction

# Hide High-Order bit from string removing it. It is implicit that the most significant bit is 1
function frac_bstring = hide_ho_bit_fractional(frac_bstring, exponent)
  frac_bstring = substr(frac_bstring, exponent + 1);
endfunction

# Hide High-Order bit from string removing it. It is implicit that the most significant bit is 1
function dec_bstring = hide_ho_bit_decimal(dec_bstring)
  if length(dec_bstring) == 1
    dec_bstring = "";
  else
    dec_bstring = substr(dec_bstring, 2);
  endif
endfunction

# Converts fractionary part of the number to a bitstring with 'len' characters
function string = frac2bin(fractional, len)
  string = "";
  frac_bits = 0;
  frac = fractional;

  while frac != 0 && frac_bits < len
    frac = frac * 2;
    if frac > 1
      frac = frac - floor(frac);
      string = strcat(string, "1");
    else
      string = strcat(string, "0");
    endif
    frac_bits++;
  endwhile
endfunction


# Validates string that must be representing a number in either base 2 or 10
function value_string = is_numeric_input(string, is_binary)
  if all(isstrprop(string, "digit"))
    if is_binary
      pass_if_binary(string);
    endif
    value_string = string;
  else
    printf("Invalid format. Was expecting a number. Terminating execution.");
    exit;
  endif
endfunction

# Strips sign from input string and return an indicator 1 for + or -1 for -.
# Returns the absolute value of the number in a string too.
function [string, sign] = strip_sign_from_string(string)
  sign = "0";
  # Strips sign
  if string(1) == '-' || string(1) == '+'
    if string(1) == '-'
      sign = "1";
    endif
    string = substr(string, 2);
  endif
endfunction

# Converts input string to the expected number string
function [value_bstring, sign] = input_to_number(string)
  # Strips sign from string
  [string, sign] = strip_sign_from_string(string);

  # Base 2 number
  if string(length(string)) == 'b' && length(string) > 1
    # Remove 'b' character
    string = substr(string, 1, length(string) - 1);

    occ = strchr(string, '.');
    # Integer number
    if length(occ) == 0
      value_string = is_numeric_input(string, true);
    # Floating point number. Format accepted is [0-1]+\.[0-1]+
    elseif length(occ) == 1 && occ > 1 && occ < length(string)
      dec_string = is_numeric_input(substr(string, 1, occ - 1), true);
      frac_string = is_numeric_input(substr(string, occ + 1), true);
      # If it reach this point, we can assign string to value without needing to concatenate,
      # otherwise is the program would be terminated in binary_input_to_bstring. This guarantees
      # the string is in expected format.
      value_bstring = string;
    # Error
    else
      printf("Invalid format. Bad use of floating point string detected. Accepted format for float is '[0-1]+\.[0-1]+'. Terminating execution.");
      exit;
    endif

  # Base 10 number
  else
    occ = strchr(string, '.');
    # Integer number
    if length(occ) == 0
      value_string = is_numeric_input(string, false);
      value_bstring = decimal_integer_string_to_bstring(value_string);
    # Floating point number. Format accepted is [0-9]+\.[0-9]+
    elseif length(occ) == 1 && occ > 1 && occ < length(string)
      dec_string = is_numeric_input(substr(string, 1, occ - 1), false);
      frac_string = is_numeric_input(substr(string, occ + 1), false);

      dec_bstring = decimal_integer_string_to_bstring(dec_string);
      frac_bstring = fractional_integer_string_to_bstring(frac_string);

      value_bstring = strcat(dec_bstring, strcat(".", frac_bstring));
    # Error
    else
      printf("Invalid format. Bad use of floating point string detected. Accepted format for float is '[0-9]+\.[0-9]+'. Terminating execution.");
      exit;
    endif
  endif
endfunction

# Converts a decimal integer string to a binary string
function bstring = decimal_integer_string_to_bstring(string)
  bstring = "";
  quocient_number = 1;

  while quocient_number > 0
    digit = 1;
    dividend_str = quocient_str = "";
    while digit <= length(string)
      dividend_str = strcat(dividend_str, string(digit));
      dividend = str2num(dividend_str);
      remainder = rem(dividend, 2);
      quocient_number = floor(double(dividend) / 2);
      quocient_str = strcat(quocient_str, num2str(quocient_number));
      dividend_str = num2str(remainder);
      digit++;
    endwhile
    string = quocient_str;
    quocient_number = str2num(quocient_str);
    bstring = strcat(num2str(remainder), bstring);
  endwhile
endfunction

# Converts a fractional integer string to a binary string
function bstring = fractional_integer_string_to_bstring(string)
  count = 0;
  bstring = "";
  unfinished = true;

  while unfinished
    multiplied_str = "";
    digit = length(string);
    carry = 0; all_zero = true;
    while digit > 0
      bit_result_str = num2str(carry + (2 * str2num(string(digit))));
      if length(bit_result_str) == 1
        carry = 0;
      else
        carry = 1;
      endif

      multiplied_str = strcat(bit_result_str(length(bit_result_str)), multiplied_str);

      if bit_result_str(length(bit_result_str)) != "0"
        all_zero = false;
      endif
      digit--;
    endwhile
    string = multiplied_str;
    bstring = strcat(bstring, num2str(carry));

    count++;
    if all_zero || count == 127
      unfinished = false;
    endif
  endwhile
endfunction

# Scans user keyboard. If exit command found, terminates program.
function string = scan_keyboard(message)
  while length(string = input(message, "s")) <= 0
    continue;
  endwhile

  string = strtrim(string);

  if strcmpi(string, "exit")
    printf("All done. Terminating execution.");
    exit;
  endif
endfunction

# Print word (4bytes) of IEEE Single Format that represents a given number
function print_word(ieee_string)
  sign = ieee_string(1);
  exponent = ieee_string(2:9);
  significant = ieee_string(10:32);
  guard = ieee_string(33:34);
  printf("[ %c | ", sign);
  printf("%c ", exponent); printf("| ");
  printf("%c ", significant); printf("] || Guard Bits: [");
  printf(" %c ", guard);printf("]\n");
endfunction

# Check whether the string contains only the characters '0' or '1'. If not, terminates execution.
function pass_if_binary(string)
  i = 1;
  while i <= length(string)
    if string(i) != '0' && string(i) != '1'
      printf("Invalid format. Was expecting a binary string. Terminating execution.");
      exit;
    endif
    i++;
  endwhile
endfunction

main();
