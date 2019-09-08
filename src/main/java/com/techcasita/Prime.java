package com.techcasita;

public class Prime {
    static boolean isPrime(final long n) {
        if (n < 2) {
            return false;
        }
        if (n == 2 || n == 3) {
            return true;
        }
        if (n % 2 == 0) {
            return false;
        }
        if (n % 3 == 0) {
            return false;
        }
        final long sqrtN = (long) Math.sqrt(n) + 1;
        for (long i = 6; i <= sqrtN; i += 6) {
            if (n % (i - 1) == 0) {
                return false;
            }
            if (n % (i + 1) == 0) {
                return false;
            }
        }
        return true;
    }
}
