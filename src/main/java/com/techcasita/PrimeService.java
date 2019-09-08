package com.techcasita;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet("/isPrime/*")
public class PrimeService extends HttpServlet {
    private static final Logger Log = LogManager.getLogger(PrimeService.class);

    static {
        Log.info("PrimeService initialized ...");
    }

    public void doGet(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        String result;
        try {
            long k = Long.parseLong(request.getPathInfo().substring(1));
            result = String.format("%d is%s a prime number.", k, Prime.isPrime(k) ? "" : " not");
        } catch (NumberFormatException e) {
            Log.warn(request.getPathInfo() + "\n" + e.toString());
            result = "Input could not be interpreted as a valid number";
        }
        response.getWriter().println(result);
    }
}
