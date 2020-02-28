#!/usr/bin/env python3

from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse, parse_qs
import socket
import traceback
import re
from collections import deque
import mysql.connector as myconn

class Inventory:
    def __init__(self, table):
        self.table = table

    def addstock(self, name, amount=1):
        try:
            amount = int(amount)
            price = 0
            sell = 0
            conn = myconn.connect(user="tuimac", password="P@ssw0rd", host="localhost", database="INVENTORY")
            cur = conn.cursor()
            sql = "SELECT name FROM {} WHERE BINARY name = %s".format(self.table)
            cur.execute(sql, (name, ))
            if cur.fetchone() == None:
                sql = "INSERT INTO {} (name, amount, price, sell) VALUES (%s, %s, %s, %s)".format(self.table)
                cur.execute(sql, (name, amount, price, sell))
                conn.commit()
            else:
                sql = "UPDATE {} SET amount = %s WHERE name = %s".format(self.table)
                cur.execute(sql, (amount, name))
                conn.commit()
            cur.close()
            conn.close()
            return ""
        except:
            traceback.print_exc()
            return "ERROR\n"

    def checkstock(self, name=""):
        conn = myconn.connect(user="tuimac", password="P@ssw0rd", host="localhost", database="INVENTORY")
        cur = conn.cursor()
        body = ""
        if name == "":
            sql = "SELECT name, amount FROM {}".format(self.table)
            cur.execute(sql)
        else:
            sql = "SELECT name, amount FROM {} WHERE name=%s;".format(self.table)
            cur.execute(sql, (name, ))
        for row in cur.fetchall():
            body += row[0] + ": " + str(row[1]) + "\n"
        cur.close()
        conn.close()
        return body

    def sell(self, name, amount=1, price=0):
        try:
            conn = myconn.connect(user="tuimac", password="P@ssw0rd", host="localhost", database="INVENTORY")
            cur = conn.cursor()
            body = ""
            sql = "SELECT amount, sell FROM {} where name = %s".format(self.table)
            cur.execute(sql, (name, ))
            for rows in cur.fetchall():
                after = rows[0] - int(amount)
                sell = rows[1]
                if price == 0:
                    sql = "UPDATE {} SET amount = %s WHERE name = %s".format(self.table)
                    cur.execute(sql, (after, name))
                else:
                    sell = int(sell) + int(amount) * int(price)
                    sql = "UPDATE {} SET amount = %s, price = %s, sell = %s WHERE name = %s".format(self.table)
                    cur.execute(sql, (after, price, sell, name))
                conn.commit()
            cur.close()
            conn.close()
            return ""
        except:
            traceback.print_exc()
            return "ERROR\n"

    def checksales(self):
        conn = myconn.connect(user="tuimac", password="P@ssw0rd", host="localhost", database="INVENTORY")
        cur = conn.cursor()
        body = ""
        sum = 0
        sql = "SELECT sell FROM {}".format(self.table)
        cur.execute(sql)
        for rows in cur.fetchall():
            sum += rows[0]
        body += "sales: " + str(sum) + "\n"
        cur.close()
        conn.close()
        return body

    def deleteall(self):
        conn = myconn.connect(user="tuimac", password="P@ssw0rd", host="localhost", database="INVENTORY")
        cur = conn.cursor(buffered=True)
        sql = "SELECT id FROM {}".format(self.table)
        cur.execute(sql)
        sql = "DROP TABLE {};".format(self.table)
        cur.execute(sql)
        cur.execute("""
            CREATE TABLE {} (
                `id` int auto_increment primary key,
                `name` varchar(50) binary unique not null,
                `amount` int,
                `price` int,
                `sell` int
            )
        """.format(self.table))
        cur.close()
        conn.close()
        return ""

    def funcSwitch(self, query):
        function = query["function"][0]
        if function == "addstock":
            result = ""
            if not "amount" in query:
                result = self.addstock(query["name"][0])
            else:
                result = self.addstock(query["name"][0], query["amount"][0])
            return result
        elif function == "checkstock":
            result = ""
            if not "name" in query:
                result = self.checkstock()
            else:
                result = self.checkstock(query["name"][0])
            return result
        elif function == "sell":
            result = ""
            if not "price" in query:
                result = self.sell(query["name"][0], query["amount"][0])
                return result
            elif not "amount" in query:
                result = self.sell(query["name"][0], 1, query["price"][0])
                return result
            else:
                result = self.sell(query["name"][0], query["amount"][0], query["price"][0])
                return result
        elif function == "checksales":
            result = ""
            result = self.checksales()
            return result
        elif function == "deleteall":
            result = ""
            result = self.deleteall()
            return result

class ServerHandler(BaseHTTPRequestHandler):
    def createBody(self, query):
        invent = Inventory("inventory")
        body = invent.funcSwitch(query)
        return str(body)

    def do_GET(self):
        param = urlparse(self.path)
        query = parse_qs(param.query)

        body = self.createBody(query)

        self.send_response(200)
        self.send_header("Content-type", "text/html; charset=utf-8")
        self.send_header("Content-length", len(body.encode()))
        self.end_headers()
        self.wfile.write(body.encode())

def main():
    try:
        port = 8080
        host = socket.gethostbyname("0.0.0.0")
        httpServer = HTTPServer((host, port), ServerHandler)
        httpServer.serve_forever()
    except:
        traceback.print_exc()

if __name__ == "__main__":
    main()
