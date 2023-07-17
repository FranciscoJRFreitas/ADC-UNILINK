/**
 * The RecoverPwdHTMLLoader class is responsible for loading and replacing tokens in an HTML file used
 * for password recovery.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class RecoverPwdHTMLLoader {
    /**
     * The function `loadHTML` loads the contents of a HTML file, replaces a placeholder with a given
     * token, and returns the modified HTML as a string.
     * 
     * @param token The "token" parameter is a string that represents a token used for password reset.
     * @return The method is returning a String that represents the contents of the "pwdReset.html"
     * file, with the "{TOKEN}" placeholder replaced with the value of the "token" parameter.
     */
    public static String loadHTML(String token) {
        try (InputStream inputStream = RecoverPwdHTMLLoader.class.getResourceAsStream("/pwdReset.html")) {
            assert inputStream != null;
            try (InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                 BufferedReader reader = new BufferedReader(inputStreamReader)) {
                String line;
                StringBuilder sb = new StringBuilder();
                while ((line = reader.readLine()) != null) {
                    sb.append(line).append("\n");
                }
                return sb.toString().replace("{TOKEN}", token);
            }
        } catch (IOException e) {
            throw new RuntimeException("Unable to load pwdReset.html", e);
        }
    }
}

