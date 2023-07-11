package pt.unl.fct.di.apdc.firstwebapp.util;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class RecoverPwdHTMLLoader {
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
