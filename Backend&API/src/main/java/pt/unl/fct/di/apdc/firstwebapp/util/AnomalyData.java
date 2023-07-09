package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.UUID;

public class AnomalyData {
    public String id;
    public String title;
    public String description;
    public String coordinates;
    public String sender;

    public AnomalyData() {}

    public AnomalyData(String title, String description, String coordinates, String sender) {
        this.id = UUID.randomUUID().toString();
        this.sender = sender;
        this.title = title;
        this.description = description;
        this.coordinates = coordinates;
    }
}
