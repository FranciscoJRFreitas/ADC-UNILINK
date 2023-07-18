/**
 * The EventData class is a Java class that represents the data of an event, including its creator,
 * type, title, description, start and end time, group ID, and location.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

public class EventData {

    public String creator;
    public String type;
    public String title;
    public String description;
    public String startTime;
    public String endTime;
    public String groupID;
    public String location;

    public EventData() {}

    public EventData(String creator, String type, String title, String description, String startTime, String endTime, String groupID, String location){
        this.creator = creator;
        this.type = type;
        this.title = title;
        this.description = description;
        this.startTime = startTime;
        this.endTime = endTime;
        this.groupID = groupID;
        this.location = location;
    }

}
