import java.io.*;
import java.util.*;

public class Longcat {
    public static void main(String[] args) throws Exception {
        System.out.println("Behold, the Longcat is loooooong!");
        System.out.println();
        Scanner in = new Scanner(new File("longcat.txt"));
        while (in.hasNextLine()) {
            System.out.println(in.nextLine());
        }
    }
}
