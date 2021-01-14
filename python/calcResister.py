#!/usr/bin/env python3

def together(x, y):
    result = (x << 16) + y
    print('x_Decimal: ' + str(x))
    x_bin = ''
    while x > 0:
        x_bin = str(x % 2) + x_bin
        x = x // 2
    print('x_Binary: ' + x_bin + '\n')
    print('y_Decimal: ' + str(y))
    y_bin = ''
    while y > 0:
        y_bin = str(y % 2) + y_bin
        y = y // 2
    print('y_Binary: ' + y_bin + '\n')
    tmp = result
    print('result_unsigned_Decimal: ' + str(result))
    tmp_bin = ''
    while tmp > 0:
        tmp_bin = str(tmp % 2) + tmp_bin
        tmp = tmp // 2
    print('result_unsigned_Binary: ' + tmp_bin + '\n')
    return result

def convertToSigned(number):
    if (1 << 31) - 1 < number:
        return ((1 << 32) - number) * (-1)
    else:
        return value
if __name__ == '__main__':
    x = 65535
    y = 65480
    result = together(x, y)
    print('Unsigned Long value: ' + str(result))
    result = convertToSigned(result)
    print('Singed Long value: ' + str(result))
