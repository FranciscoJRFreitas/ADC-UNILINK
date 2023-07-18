/**
 * The VerifyAction class checks if a user with a certain role can execute a specific action on a
 * target user with a certain role.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;

public class VerifyAction {
    private static final JsonObject roles = RolesLoader.loadRoles();

    /**
     * The function checks if a user with a certain role can execute a specific action on a target user
     * with a certain role, based on their respective levels and permissions.
     * 
     * @param userRole The userRole parameter represents the role of the user who is trying to execute
     * an action. It is a string that specifies the user's role, such as "admin", "manager", or "user".
     * @param targetUserRole The targetUserRole parameter represents the role of the user for whom we
     * want to check if the action can be executed.
     * @param action The "action" parameter represents the specific action that the user wants to
     * execute. It could be any action that is defined in the roles and permissions system, such as
     * "read", "write", "delete", etc.
     * @return The method is returning a boolean value.
     */
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

    /**
     * The function checks if a user with a certain role can execute a specific action on a target user
     * with a certain role.
     * 
     * @param userRole The userRole parameter represents the role of the user who wants to execute an
     * action. It is of type UserRole.
     * @param targetUserRole The targetUserRole parameter represents the role of the user for whom the
     * action is being checked.
     * @param action The "action" parameter represents the specific action that the user wants to
     * execute. It could be any action that is defined in the system, such as "create", "read",
     * "update", or "delete".
     * @return The method is returning a boolean value.
     */
    public static boolean canExecute(UserRole userRole, UserRole targetUserRole, String action) {
        String user = userRole.toString();
        String targetUser = targetUserRole.toString();
        return canExecute(user, targetUser, action);
    }
}
