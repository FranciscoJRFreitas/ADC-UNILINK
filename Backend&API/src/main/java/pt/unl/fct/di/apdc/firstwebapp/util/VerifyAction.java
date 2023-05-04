package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

public class VerifyAction {
    private static final JsonObject roles = RolesLoader.loadRoles();

    public static boolean canExecute(String userRole, String targetUserRole, String action) {
        if (userRole.equals(UserRole.SU.toString()))
            return true;

        JsonObject userRoleObject = roles.get("roles").getAsJsonObject().get(userRole).getAsJsonObject();
        JsonObject targetUserRoleObject = roles.get("roles").getAsJsonObject().get(targetUserRole).getAsJsonObject();

        int userLevel = userRoleObject.get("level").getAsInt();
        int targetUserLevel = targetUserRoleObject.get("level").getAsInt();

        if (userLevel < targetUserLevel) {
            return false;
        }

        JsonArray permissions = userRoleObject.get(action).getAsJsonArray();

        for (JsonElement permission : permissions) {
            if (permission.getAsString().equals(targetUserRole)) {
                return true;
            }
        }
        return false;
    }
    public static boolean canExecute(UserRole userRole, UserRole targetUserRole, String action) {
        String user = userRole.toString();
        String targetUser = targetUserRole.toString();
        return canExecute(user, targetUser, action);
    }
}
