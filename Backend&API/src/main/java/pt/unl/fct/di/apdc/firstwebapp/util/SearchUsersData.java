/**
 * The SearchUsersData class is a utility class in Java that represents the data needed for searching
 * users.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

public class SearchUsersData {

    public String username;
    public String searchQuery;

    public SearchUsersData() {}

    public SearchUsersData(String username, String token, String searchQuery) {
        this.username = username;
        this.searchQuery = searchQuery;
    }

}
