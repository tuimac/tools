import java.util.*;
import java.math.*;

public class Real4 {
    static long jointInputs(int x, int y){
        // Return jointed binary which consist of Register 33 and Register 34.
        return (x << 16) + y;
    }

    static void printBinary(long input){
        long tmp = input;
        String result = "";
        while(input > 0){
            result = Long.toString(input % 2) + result;
            input = input / 2;
        }
        System.out.println();
        System.out.print("Decimal: ");
        System.out.println(tmp);
        System.out.print("Binary: ");
        System.out.println(result);
        System.out.println();
    }

    static float convertToFloat(long input){
        long exponent = input >> 22;
        if(exponent > (1 << 8)) {
            exponent = exponent - (1 << 8);
        }
        exponent -= 127;
        System.out.println(exponent);

        long tmp = input - (input >> 22);
        float fraction = 0;
        int index = 1;

        for(int i = 22; i >= 0; i--){
            tmp = (tmp & (1 << i)) >> i;
            if(tmp % 2 == 1){
                fraction += (float) Math.pow(2, index * -1);
            }
            tmp = tmp / 2;
            index++;
        }
        System.out.println(Math.pow(-1, (input & (1 << 31)) >> 31));
        System.out.println(Math.pow(2, exponent));
        System.out.println(fraction);

        float result = (float) (Math.pow(-1, (input & (1 << 31)) >> 31) * Math.pow(2, exponent) * fraction);
        System.out.println(result);
        return result;
    }

    public static void main(String[] args) {
        int x = 16611; // Register 34
        int y = 15568; // Register 33
        
        System.out.print("Input x");
        printBinary(x);       
        System.out.print("Input y");
        printBinary(y);

        long jointed = jointInputs(x, y);
        System.out.print("Jointed_Decimal: ");
        System.out.println(jointed);
        System.out.print("Jointed_Binary: ");
        printBinary(jointed);

        float result = convertToFloat(jointed);
        System.out.print("Result_Float: ");
        System.out.println(result);
    }
}
