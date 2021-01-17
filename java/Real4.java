import java.util.*;
import java.math.*;

public class Real4 {
    static String binaryConvertor(long input){
        long tmp = input;
        String result = "";
        while(input > 0){
            result = Long.toString(input % 2) + result;
            input = input / 2;
        }
        return result;
    }

    static long jointInputs(int x, int y){
        return (x << 16) + y;
    }

    static double convertToDecimalPoint(long input){
        double sign = Math.pow(-1, (input & (1 << 31)) >> 31);

        double exponent = Math.pow(2, (input >> 23) - 127);

        double fraction = 0;
        long tmp = input - ((input >> 23) << 23);
        int index = 23;
        while(tmp > 0){
            if(tmp % 2 == 1){
                fraction += Math.pow(2, index * -1);
            }
            tmp = tmp / 2;
            index--;
        }
        fraction++;

        return  sign * exponent * fraction;
    }

    public static void main(String[] args) {
        int x = 16611;
        int y = 15568;
        
        long jointed = jointInputs(x, y);
        double result = convertToDecimalPoint(jointed);

        System.out.print("Result_Float: ");
        System.out.println(result);
    }
}
