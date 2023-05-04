package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class RolesLoader {
    public static JsonObject loadRoles() {
        try (InputStream inputStream = RolesLoader.class.getResourceAsStream("/roles.json")) {
            assert inputStream != null;
            try (InputStreamReader inputStreamReader = new InputStreamReader(inputStream);
                 BufferedReader reader = new BufferedReader(inputStreamReader)) {
                JsonElement jsonElement = JsonParser.parseReader(reader);
                return jsonElement.getAsJsonObject();
            }
        } catch (IOException e) {
            throw new RuntimeException("Unable to load roles.json", e);
        }
    }
}