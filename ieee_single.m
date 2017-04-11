#! /usr/bin/octave -qf

# MAC0210 - Laboratório de Métodos Numéricos - 2017/1
# Exercicio Programa I - IEEE Single Representation
# Renan Fichberg - 7991131
# Professor: Ernesto G. Birgin
# Monitor: Lucas Magno

function main()
  printf("\nSimple IEEE Single Representation program. Usage information can be found in the documentation.\n\n")
  #a_word_vector = b_word_vector = r_word_vector = zeros(1,32);

  while true
    while length(a = input("Input value for A:\n>> ", "s")) <= 0
      continue;
    endwhile
    a_value = input_to_number(a);
    a_word_vector = number_to_ieee_single(a_value);
    print_word(a_word_vector);
    while length(b = input("Input value for B:\n>> ", "s")) <= 0
      continue;
    endwhile
    b_value = input_to_number(b);
    b_word_vector = number_to_ieee_single(b_value);
    print_word(b_word_vector);
    while length(op = input("Select an operation (+ or -):\n>> ", "s")) <= 0
      continue;
    endwhile
    #word_vector = operate(op, a_value, b_value);
    #print_word(r_word_vector);
  endwhile
endfunction

function word_vector = number_to_ieee_single(number)
  exp = 0;
  fractional_part = abs(number) - floor(abs(number));
  decimal_part = abs(number) - fractional_part;

  if number >= 0
    word_vector = build_iee_single_representation(decimal_part, fractional_part, exp, "0");
  else
    word_vector = build_iee_single_representation(decimal_part, fractional_part, exp, "1");
  endif
endfunction

function word_vector = build_iee_single_representation(decimal, fractional, exp, sign_bstring)
  dec = decimal;
  significand_bstring = "";

  # Significand bits

  # Decimal part
  while dec > 0
    remainder = rem(dec, 2);
    dec = floor(dec / 2);
    significand_bstring = strcat(num2str(remainder), significand_bstring);
  endwhile

  if length(significand_bstring) > 0
    exp = length(significand_bstring) - 1;
    temp = significand_bstring;
    significand_bstring = "";
    i = 0;
    while i < exp
      significand_bstring = strcat(significand_bstring, temp(i + 2));
      i++;
    endwhile
  endif

  # Fractionary part
  if strcmp(significand_bstring, "") && decimal == 0
    leading_zero = 1;
  else
    leading_zero = 0;
  endif

  counter = 0;
  while fractional != 0 && counter < 23
    fractional = fractional * 2;
    if fractional >= 1
      fractional = fractional - floor(fractional);
      # Hidden bit
      if leading_zero
        leading_zero = 0;
        exp--;
        continue;
      endif
      significand_bstring = strcat(significand_bstring, "1");

    else
      if leading_zero
        exp--;
        continue;
      endif
      significand_bstring = strcat(significand_bstring, "0");
    endif

    counter++;
  endwhile

  # Fill remaining bits with bit 0
  while counter < 23
    significand_bstring = strcat(significand_bstring, "0");
    counter++;
  endwhile

  # Exponent bits
  exp_bstring = dec2bin(127 + exp, 8);

  # Build word
  word_vector = strcat(sign_bstring ,strcat(exp_bstring, significand_bstring));
endfunction

function value = input_to_number(user_input)
  if strncmpi("exit", user_input = strtrim(user_input), 4) == 1
    printf("All done. Terminating execution.");
    exit;
  endif

  # Handle sign
  sign = 1;
  if user_input(1) == '-'
    sign = -1;
    temp = user_input;
    user_input = "";
    i = 2;
    while i <= length(temp)
      user_input = strcat(user_input, temp(i));
      i++;
    endwhile
    if i == 2
      printf("Invalid input. Found a '-' sign but no digit. Terminating execution.");
      exit;
    endif
  elseif user_input(1) == '+'
    temp = user_input;
    user_input = "";
    i = 2;
    while i <= length(temp)
      user_input = strcat(user_input, temp(i));
      i++;
    endwhile
    if i == 2
      printf("Invalid input. Found a '+' sign but no digit. Terminating execution.");
      exit;
    endif
  endif

  occurrences = strchr(user_input, '.');
  if length(occurrences) == 0
    value = integer_number(user_input);
    value = value * sign;
  elseif length(occurrences) == 1
    value = floating_point_number(user_input);
    value = value * sign;
  else
    printf("Invalid character found. Maximum number of '.' character allowed is 1. Terminating execution.");
    exit;
  endif
endfunction

function value = integer_number(user_input)
  input_size = length(user_input);
  number = 0;

  if (user_input(input_size) == 'b' || user_input(input_size) == 'd') && input_size  == 1
    printf("Invalid input format. Missing digits. Terminating execution.");
    exit
  endif

  # May be a binary number
  if user_input(input_size) == 'b'
    size = index = input_size - 1;
    while index > 0
      if isstrprop(user_input(index), "digit") && str2num(user_input(index)) < 2
        number += str2num(user_input(index)) * (2 ** (size - index));
      else
        printf("Invalid character found. Was expecting '0' or '1' for binary format input. Terminating execution.");
        exit;
      endif
      index--;
    endwhile

  # May be a real number
  elseif user_input(input_size) == 'd' || isstrprop(user_input(input_size), "digit")
    if user_input(input_size) == 'd'
      size = input_size - 1;
    elseif isstrprop(user_input(input_size), "digit")
      size = input_size;
    endif
    index = size;
    while index > 0
      if isstrprop(user_input(index), "digit")
        number += str2num(user_input(index)) * (10 ** (size - index));
      else
        printf("Invalid character found. Was expecting an integer. Terminating execution.");
        exit;
      endif
      index--;
    endwhile

  # Incorrect value detected on last character. Unexpected string format.
  else
    printf("Invalid character found. Check documentation to see the expected input formats. Terminating execution.");
    exit;
  endif

  value = number;
endfunction

function value = floating_point_number(user_input)
  input_size = length(user_input);
  floating_point_position = strchr(user_input, '.');
  number = 0;

  if ((user_input(input_size) == 'b' || user_input(input_size) == 'd') && input_size - floating_point_position == 1) || input_size == floating_point_position
    printf("Invalid input format. Detected character '.' but no fraction part. Terminating execution.");
    exit
  endif

  if (user_input(input_size) == 'b' || user_input(input_size) == 'd') && input_size  == 1
    printf("Invalid input format. Missing digits. Terminating execution.");
    exit
  endif

  # May be a binary number
  if user_input(input_size) == 'b'
    size = input_size - 1;
    index = floating_point_position - 1;

    # Decimal part
    while index > 0
      if isstrprop(user_input(index), "digit") && str2num(user_input(index)) < 2
        number += str2num(user_input(index)) * (2 ** (floating_point_position - 1 - index));
      else
        printf("Invalid character found. Was expecting '0' or '1' for binary format input. Terminating execution.");
        exit;
      endif
      index--;
    endwhile

    # Fraction part
    index = floating_point_position + 1;
    while index <= size
      if isstrprop(user_input(index), "digit") && str2num(user_input(index)) < 2
        number += str2num(user_input(index)) * (2 ** ((index - floating_point_position) * (-1)));
      else
        printf("Invalid character found. Was expecting '0' or '1' for binary format input. Terminating execution.");
        exit;
      endif
      index++;
    endwhile

  # May be a real number
  elseif user_input(input_size) == 'd' || isstrprop(user_input(input_size), "digit")
    if user_input(input_size) == 'd'
      size = input_size - 1;
    elseif isstrprop(user_input(input_size), "digit")
      size = input_size;
    endif
    index = floating_point_position - 1;

    # Decimal part
    while index > 0
      if isstrprop(user_input(index), "digit")
        number += str2num(user_input(index)) * (10 ** (floating_point_position - 1 - index));
      else
        printf("Invalid character found. Was expecting an integer. Terminating execution.");
        exit;
      endif
      index--;
    endwhile

    # Fraction part
    index = floating_point_position + 1;
    while index <= size
      if isstrprop(user_input(index), "digit")
        number += str2num(user_input(index)) * (10 ** ((index - floating_point_position) * (-1)));
      else
        printf("Invalid character found. Was expecting an integer. Terminating execution.");
        exit;
      endif
      index++;
    endwhile

  # Incorrect value detected on last character. Unexpected string format.
  else
    printf("Invalid character found. Check documentation to see the expected input formats. Terminating execution.");
    exit;
  endif

  value = number;
endfunction

function print_word(word_vector)
  sign = word_vector(1);
  exponent = word_vector(2:9);
  significand = word_vector(10:32);
  printf("[  %c  |  ", sign);
  printf("%c  ", exponent); printf("|  ");
  printf("%c  ", significand); printf("]\n");
endfunction

main();
