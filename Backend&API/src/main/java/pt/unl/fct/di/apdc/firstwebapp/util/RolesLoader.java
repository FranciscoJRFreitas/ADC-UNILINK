/**
 * The RolesLoader class is responsible for loading a JSON file containing roles and returning it as a
 * JsonObject.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;

public class RolesLoader {
    /**
     * The function `loadRoles()` loads a JSON file containing roles and returns it as a `JsonObject`.
     * 
     * @return The method is returning a JsonObject.
     */
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