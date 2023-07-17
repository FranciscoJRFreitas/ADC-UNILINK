/**
 * The Group class represents a group with a display name, description, admin ID, and a list of
 * participants.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.List;

public class 
Group {

    public String DisplayName;
    public String description;
    public String adminID;
    public List<String> participants;

    public Group() {}

    public Group(String DisplayName, String description, String adminID) {
        this.DisplayName = DisplayName;
        this.description = description;
        this.adminID = adminID;
    }
    public Group(String DisplayName, String description, String adminID, List<String> participants) {
        this.DisplayName = DisplayName;
        this.description = description;
        this.adminID = adminID;
        this.participants = participants;
    }

}
