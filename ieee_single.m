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
    a = input("Input value for A:\n>> ", "s");
    a_value = input2decimal(a);
    b = input("Input value for B:\n>> ", "s");
    b_value = input2decimal(b);
    op = input("Select an operation (+ or -):\n>> ", "s");
    #word_vector = operate(op, a_value, b_value);
    print_word(word_vector);
  endwhile
endfunction

function value = input2decimal(user_input)
  input_size = length(user_input);

  # May be a binary number
  if user_input(input_size) == 'b'
    size = index = input_size - 1;
    number = 0;
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
    number = 0;
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

function print_word(word_vector)
  sign = word_vector(1);
  exponent = word_vector(2:9);
  significand = word_vector(10:32);
  printf("[  %d  |  ", sign);
  printf("%d  ", exponent); printf("|  ");
  printf("%d  ", significand); printf("]\n");
endfunction

main();
