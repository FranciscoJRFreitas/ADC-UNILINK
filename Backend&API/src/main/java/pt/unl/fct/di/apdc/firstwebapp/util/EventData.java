package pt.unl.fct.di.apdc.firstwebapp.util;

public class EventData {

    public String creator;
    public String title;
    public String description;
    public String startTime;
    public String endTime;

    public EventData() {}

    public EventData(String creator, String title, String description, String startTime, String endTime){
        this.creator = creator;
        this.title = title;
        this.description = description;
        this.startTime = startTime;
        this.endTime = endTime;
    }

}
