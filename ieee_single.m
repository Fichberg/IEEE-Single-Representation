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
    a = scan_keyboard("Input value for A:\n>> ");
    a_value = input_to_number(a);
    #a_word_vector = number_to_ieee_single(a_value);
    #print_word(a_word_vector);

    b = scan_keyboard("Input value for B:\n>> ");
    b_value = input_to_number(b);
    #b_word_vector = number_to_ieee_single(b_value);
    #print_word(b_word_vector);

    op = scan_keyboard("Select an operation (+ or -):\n>> ");

    #word_vector = operate(op, a_value, b_value);
    #print_word(r_word_vector);
  endwhile
endfunction

# Converts input string representing a number in base 2 to an integer number
function value = integer_binary_number(string)
  if all(isstrprop(string, "digit"))
    pass_if_binary(string);
    value = int64(bin2dec(string));
  else
    printf("Invalid format. Was expecting a number.");
    exit;
  endif
endfunction

# Converts input string representing a number in base 10 to an integer number
function value = integer_number(string)
  if all(isstrprop(string, "digit"))
    value = int64(str2num(string));
  else
    printf("Invalid format. Was expecting a number.");
    exit;
  endif
endfunction

# Converts input string representing a number in base 2 to a float number
function value = float_binary_number(dec_string, frac_string)
  if all(isstrprop(dec_string, "digit")) && all(isstrprop(frac_string, "digit"))
    pass_if_binary(dec_string); pass_if_binary(frac_string);
    value = double(bin2dec(dec_string));

    exp = 1;
    while exp <= length(frac_string)
      value = value + (double(str2num(frac_string(exp))) * double((2 ** (-1 * exp))));
      exp++;
    endwhile
  else
    printf("Invalid format. Was expecting a number.");
    exit;
  endif
endfunction

# Converts input string representing a number in base 10 to a float number
function value = float_number(dec_string, frac_string)
  if all(isstrprop(dec_string, "digit")) && all(isstrprop(frac_string, "digit"))
    value = str2double(strcat(dec_string, strcat(".", frac_string)));
  else
    printf("Invalid format. Was expecting a number.");
    exit;
  endif
endfunction

# Check whether the string contains only the characters '0' or '1'. If not, terminates execution.
function pass_if_binary(string)
  i = 1;
  while i <= length(string)
    if string(i) != '0' && string(i) != '1'
      printf("Invalid format. Was expecting a binary string.");
      exit;
    endif
    i++;
  endwhile
endfunction

# Converts input string to a number
function value = input_to_number(string)
  # Base 2 number
  if string(length(string)) == 'b' && length(string) > 1
    # Remove 'b' character
    string = substr(string, 1, length(string) - 1);

    occ = strchr(string, '.');
    # Integer number
    if length(occ) == 0
      value = integer_binary_number(string);
    # Floating point number. Format accepted is [0-1]+\.[0-1]+
    elseif length(occ) == 1 && occ > 1 && occ < length(string)
      dec_string = substr(string, 1, occ - 1);
      frac_string = substr(string, occ + 1);
      value = float_binary_number(dec_string, frac_string);
    # Error
    else
      printf("Invalid format. Bad use of floating point string detected. Accepted format for float is '[0-1]+\.[0-1]+'.");
      exit;
    endif

  # Base 10 number
  else
    occ = strchr(string, '.');
    # Integer number
    if length(occ) == 0
      value = integer_number(string);
    # Floating point number. Format accepted is [0-9]+\.[0-9]+
    elseif length(occ) == 1 && occ > 1 && occ < length(string)
      dec_string = substr(string, 1, occ - 1);
      frac_string = substr(string, occ + 1);
      value = float_number(dec_string, frac_string);
    # Error
    else
      printf("Invalid format. Bad use of floating point string detected. Accepted format for float is '[0-1]+\.[0-1]+'.");
      exit;
    endif
  endif
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
function print_word(word_vector)
  sign = word_vector(1);
  exponent = word_vector(2:9);
  significand = word_vector(10:32);
  printf("[  %c  |  ", sign);
  printf("%c  ", exponent); printf("|  ");
  printf("%c  ", significand); printf("]\n");
endfunction

# Converts number to IEEE Single Format
function word_vector = number_to_ieee_single(number)
  printf("%d %d\n",  int64(number), number);
  fractional = abs(number) - floor(abs(number));
  decimal = abs(number) - fractional;

  word_vector = build_iee_single_representation(decimal, fractional);
endfunction

# Constructs string representing the number in IEEE Single Format
function word_vector = build_iee_single_representation(decimal, fractional)
  dec_bstring = frac_bstring = "";
  dec_bits = frac_bits = 0;
  frac = fractional;
  dec = decimal;

  # Decimal part
  while dec > 0 && dec_bits < 23
    remainder = rem(dec, 2);
    dec = floor(dec / 2);
    dec_bstring = strcat(num2str(remainder), dec_bstring);
    dec_bits++;
  endwhile

  printf("%s\n", dec_bstring);

  # Fractionary part
  while frac != 0 && frac_bits < 127
    frac = frac * 2;
    if frac >= 1
      frac = frac - floor(frac);
      frac_bstring = strcat(frac_bstring, "1");
    else
      frac_bstring = strcat(frac_bstring, "0");
    endif

    frac_bits++;
  endwhile

  word_vector = "";
endfunction

main();
