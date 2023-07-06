package pt.unl.fct.di.apdc.firstwebapp.util;

import java.util.UUID;

public class AnomalyData {
    public String AnoamlyID;
    public String description;

    public AnomalyData() {}

    public AnomalyData(String description) {
        this.AnoamlyID = UUID.randomUUID().toString();
        this.description = description;
    }
}
