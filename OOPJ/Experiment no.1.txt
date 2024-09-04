public class spring {

    public static void main(String[] args) {
        // Example of a for loop
        System.out.println("using For Loop:");
        for (int i = 0; i < 5; i++) {
            if (i == 3) {
                System.out.println("Breaking out of the loop at i = " + i);
                break; // Exiting the loop when i == 3
            }
            System.out.println("i = " + i);
        }

        // Example of a while loop
        System.out.println("\nusing While Loop:");
        int j = 0;
        while (j < 5) {
            if (j == 2) {
                System.out.println("Skipping the print statement when j = " + j);
                j++; // Incrementing j without using 'continue'
                continue; // Skips the rest of the loop body, not recommended but using to demonstrate
            }
            System.out.println("j = " + j);
            j++;
        }

        // Example of a do-while loop
        System.out.println("\nusing Do-While Loop:");
        int k = 0;
        do {
            if (k == 4) {
                System.out.println("Exiting the program at k = " + k);
                return; // Exiting the method using return
            }
            System.out.println("k = " + k);
            k++;
        } while (k < 5);

        // If this point is reached, it means the return statement was not executed
        System.out.println("End of the program");
    }
}
