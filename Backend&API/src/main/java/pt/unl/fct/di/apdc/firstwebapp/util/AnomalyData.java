package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.UUID;

public class AnomalyData {
    public String AnoamlyID;
    public String title;
    public String description;
    public String coordinates;

    public AnomalyData() {}

    public AnomalyData(String title, String description, String coordinates) {
        this.AnoamlyID = UUID.randomUUID().toString();
        this.title = title;
        this.description = description;
        this.coordinates = coordinates;
    }
}
