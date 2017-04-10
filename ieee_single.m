#! /usr/bin/octave -qf

# MAC0210 - Laboratório de Métodos Numéricos - 2017/1
# Exercicio Programa I - IEEE Single Representation
# Renan Fichberg - 7991131
# Professor: Ernesto G. Birgin
# Monitor: Lucas Magno

function main()
  printf("\nSimple IEEE Single Representation program. Usage information can be found in the documentation.\n\n")
  word_vector = zeros(1,32);

  while true
    while length(a = input("Input value for A:\n>> ", "s")) <= 0
      continue;
    endwhile
    a_value = input_to_number(a);
    while length(b = input("Input value for B:\n>> ", "s")) <= 0
      continue;
    endwhile
    b_value = input_to_number(b);
    while length(op = input("Select an operation (+ or -):\n>> ", "s")) <= 0
      continue;
    endwhile
    #word_vector = operate(op, a_value, b_value);
    print_word(word_vector);
  endwhile
endfunction

function value = input_to_number(user_input)
  user_input = strtrim(user_input);
  occurrences = strchr(user_input, '.');
  if length(occurrences) == 0
    value = integer_number(user_input);
  elseif length(occurrences) == 1
    value = floating_point_number(user_input);
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

  # May be a decimal number
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

    # Whole part
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
    while index < input_size
      if isstrprop(user_input(index), "digit") && str2num(user_input(index)) < 2
        number += str2num(user_input(index)) * (2 ** (index * (-1)));
      else
        printf("Invalid character found. Was expecting '0' or '1' for binary format input. Terminating execution.");
        exit;
      endif
      index++;
    endwhile

  # May be a decimal number
  elseif user_input(input_size) == 'd' || isstrprop(user_input(input_size), "digit")
    if user_input(input_size) == 'd'
      size = input_size - 1;
    elseif isstrprop(user_input(input_size), "digit")
      size = input_size;
    endif
    index = floating_point_position - 1;

    # Whole part
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
    while index < input_size
      if isstrprop(user_input(index), "digit")
        number += str2num(user_input(index)) * (10 ** (index * (-1)));
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
  printf("[  %d  |  ", sign);
  printf("%d  ", exponent); printf("|  ");
  printf("%d  ", significand); printf("]\n");
endfunction

main();
