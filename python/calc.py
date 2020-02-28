#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
import socket
import traceback
import re
from collections import deque


class App:
    def calc(formula):
        try:
            def operation(operator, x=0, y=0):
                x = int(x)
                y = int(y)
                result = {
                    "+": lambda x, y: x + y,
                    "-": lambda x, y: y - x,
                    "*": lambda x, y: x * y,
                    "/": lambda x, y: x / y
                }[operator](x, y)
                return result

            if type(formula) is list:
                formula = "".join(formula)
            if re.match("[^\+\-\*\/\(\)|^\d+]", formula):
                return "ERROR"
            formula = re.findall("([\+\-\*\/\(\)]|\d+)", formula)
            numbers = deque()
            operators = deque()
            i = 0
            length = len(formula)

            while i < length:
                print(numbers)
                print(operators)
                c = formula[i]
                if c == "(":
                    numbers.append(App.calc(formula[i + 1:]))
                    for c in formula[i:]:
                        if c == ")": break
                        else: i += 1
                elif c == ")":
                    break
                elif re.match("[*/]", c):
                    y = 0
                    if formula[i + 1] == "(":
                        y = App.calc(formula[i + 1:])
                        for c in formula[i:]:
                            if c == ")":break
                            else: i += 1
                    else:
                        y = formula[i + 1]
                    numbers.append(operation(c, numbers.pop(), y))
                    i = i + 1
                elif re.match("[+-]", c):
                    operators.append(c)
                elif re.match("\d+", c):
                    numbers.append(int(c))
                i += 1

            while operators:
                if numbers:
                    x = numbers.pop()
                if numbers:
                    y = numbers.pop()
                numbers.append(operation(operators.pop(), x, y))

            answer = numbers.pop()
            if int(answer) == answer:
                return int(answer)
            else:
                return answer
        except:
            raise

class ServerHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        param = urlparse(self.path)
        query = param.query

        body = str(App.calc(query)) + "\n"

        self.send_response(200)
        self.send_header("Content-type", "text/html; charset=utf-8")
        self.send_header("Content-length", len(body.encode()))
        self.end_headers()
        self.wfile.write(body.encode())

def main():
    try:
        port = 8000
        host = socket.gethostbyname("localhost")
        httpServer = HTTPServer((host, port), ServerHandler)
        httpServer.serve_forever()
    except:
        traceback.print_exc()

if __name__ == "__main__":
    main()
