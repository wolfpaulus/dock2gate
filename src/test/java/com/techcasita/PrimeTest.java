package com.techcasita;

import org.junit.Test;

import static org.junit.Assert.*;

public class PrimeTest {

    @Test
    public void isPrime() {
        assertTrue(Prime.isPrime(2));
        assertFalse(Prime.isPrime(27));
    }
}