/**
 * The LevenshteinDistance class provides a method to calculate the Levenshtein distance between two
 * strings.
 */
package pt.unl.fct.di.apdc.firstwebapp.util;

public class LevenshteinDistance {

    /**
     * The function calculates the Levenshtein distance between two strings, which is the minimum
     * number of operations (insertion, deletion, or substitution) required to transform one string
     * into another.
     * 
     * @param a The first string to compare.
     * @param b The parameter "b" represents the second string in the Levenshtein distance calculation.
     * @return The method `levenshteinDistance` returns an integer value, which represents the
     * Levenshtein distance between two input strings `a` and `b`.
     */
    public static int levenshteinDistance(String a, String b) {
        int[][] dp = new int[a.length() + 1][b.length() + 1];

        for (int i = 0; i <= a.length(); i++) {
            for (int j = 0; j <= b.length(); j++) {
                if (i == 0) {
                    dp[i][j] = j;
                } else if (j == 0) {
                    dp[i][j] = i;
                } else {
                    dp[i][j] = Math.min(Math.min(dp[i - 1][j] + 1, dp[i][j - 1] + 1),
                            dp[i - 1][j - 1] + (a.charAt(i - 1) == b.charAt(j - 1) ? 0 : 1));
                }
            }
        }
        return dp[a.length()][b.length()];
    }
}
