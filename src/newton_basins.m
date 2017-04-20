#! /usr/bin/octave -qf

function main(args)
  [polynomial, delta, output, width, height, max] = arguments(args);
  printf("Using polynomial:\np(x) = %s\n", polyout(polynomial, 'x'));
  [x_r, y_i] = newton(polynomial, polyder(polynomial), 1 + 0.25i, delta, max);

  
  #abs(x_r + i*y_i)

endfunction



function [x_r, y_i] = newton(f, fder, x0, delta, max)
  x_now = x0;
  x_r = y_i = gap = Inf;

  # Will do 'max' + 1 iterations. If 'it' reaches 'max', the method has failed to converge.
  for it = 0:max
    derivative_on_point = polyval(fder, x_now);

    # Got a non-zero derivative
    if derivative_on_point != 0
      x_next = x_now - (polyval(f, x_now) / derivative_on_point);
      if gap > abs(x_next - x_now)
        gap = abs(x_next - x_now);
        # We got a good aproximation already?
        if gap <= delta
          x_r = real(x_next);
          y_i = imag(x_next);
          break;
        endif
      endif
      x_now = x_next;
    # Derivative equals zero ===> Ggwp.
    else
      x_r = y_i = Inf;
      break;
    endif
  endfor
endfunction

# Extract values from CLI
function [polynomial, delta, output, width, heigth, max] = arguments(args)
  # Default values
  delta = 6e-8;
  output = strcat(pwd(), "/outputs/output.txt");
  width = heigth = 3;
  max = 25;

  i = 1; p = 0;
  while i <= length(args)
    if strcmp("-p", args{i}) && (i + 1 <= length(args))
      # Not a number right after the parameter
      string = args{++i}; polynomial = [];
      if length(string) > 1 && (string(1) == '-' || string(1) == '+') && all(isstrprop(string(2:length(string)), "digit"))
        string = string;
      elseif !all(isstrprop(args{i + 1}, "digit"))
        printf("Invalid input format. Was expecting a number after '-p' parameter. Terminating execution.");
        exit;
      endif

      # Build polynomial
      polynomial = [polynomial, str2num(string)]; i++;
      while i <= length(args)
        string = args{i};
        if length(string) > 1 && (string(1) == '-' || string(1) == '+') && all(isstrprop(string(2:length(string)), "digit"))
          polynomial = [polynomial, str2num(string)];
          i++;
        elseif all(isstrprop(string, "digit"))
          polynomial = [polynomial, str2num(string)];
          i++;
        else
          break
        endif
      endwhile
      p = 1;
      continue;
    elseif strcmp("-d", args{i}) && (i + 1 <= length(args))
      if !all(isstrprop(args{i + 1}, "digit"))
        printf("Invalid input format. Was expecting a positive integer number after '-d' parameter. Terminating execution.");
        exit;
      endif
      i++; delta = 1.0 / (10 ** str2num(args{i})); i++;
      continue;
    elseif strcmp("-m", args{i}) && (i + 1 <= length(args))
      if !all(isstrprop(args{i + 1}, "digit"))
        printf("Invalid input format. Was expecting a positive integer number after '-m' parameter. Terminating execution.");
        exit;
      endif
      i++; max = str2num(args{i}); i++;
      continue;
    elseif strcmp("-o", args{i}) && (i + 1 <= length(args))
      i++; output = strcat(pwd(), strcat("/outputs/", args{i})); i++;
      continue;
    elseif strcmp("-w", args{i}) && (i + 1 <= length(args))
      if !all(isstrprop(args{i + 1}, "digit"))
        printf("Invalid input format. Was expecting a positive integer number after '-w' parameter. Terminating execution.");
        exit;
      endif
      i++; width = args{i}; i++;
      continue;
    elseif strcmp("-h", args{i}) && (i + 1 <= length(args))
      if !all(isstrprop(args{i + 1}, "digit"))
        printf("Invalid input format. Was expecting a positive integer number after '-h' parameter. Terminating execution.");
        exit;
      endif
      i++; heigth = args{i}; i++;
      continue;
    else
      printf("Invalid input format. Check out if paramaters are correct. Terminating execution.");
      exit;
    endif
  endwhile

  # Mandatory paramater
  if (p == 0)
    printf("Missing the mandatory paramater '-p'. Terminating execution.");
    exit;
  endif
endfunction





function matrix = initialize_m()
  matrix = [];
endfunction

function matrix = insert_m(matrix, integer, root)
  matrix = [matrix; [integer, root]];
endfunction

function row = lookup_m(matrix, root, delta)
  for index = 1:rows(x)
    # Element of row == index and column == 2
    if matrix(index, [,2]) == root
      row = matrix([index], [1,2])
    endif
  endfor
  row = [];
endfunction










main(argv());
