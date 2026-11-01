using System;
using System.Data;
using System.Data.SqlClient;

namespace WebAppPoliMusicV2.DAL
{
    public class Song
    {
        private string strConnectionString;

        public Song(string strConnString)
        {
            strConnectionString = strConnString;
        }

        public DataTable Read()
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] FROM [TBL_SONG]",
                    con))
                {
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                    }
                }
            }
            return dtSong;
        }

        public DataTable GetById(int idSong)
        {
            DataTable dtSong = new DataTable();
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "SELECT [ID_SONG], [SONG_NAME], [SONG_PATH], [PLAYS] " +
                    "FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    using (SqlDataAdapter sda = new SqlDataAdapter(cmd))
                    {
                        sda.Fill(dtSong);
                    }
                }
            }
            return dtSong;
        }

        public int Save(string songName, string songPath, int plays)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "INSERT INTO [TBL_SONG] ([SONG_NAME], [SONG_PATH], [PLAYS]) " +
                    "VALUES (@SONG_NAME, @SONG_PATH, @PLAYS)", con))
                {
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", songPath);
                    cmd.Parameters.AddWithValue("@PLAYS", plays);
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int Update(int idSong, string songName, string songPath, int plays)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE [TBL_SONG] SET [SONG_NAME] = @SONG_NAME, " +
                    "[SONG_PATH] = @SONG_PATH, [PLAYS] = @PLAYS " +
                    "WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    cmd.Parameters.AddWithValue("@SONG_NAME", songName);
                    cmd.Parameters.AddWithValue("@SONG_PATH", songPath);
                    cmd.Parameters.AddWithValue("@PLAYS", plays);
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }

        public int Delete(int idSong)
        {
            using (SqlConnection con = new SqlConnection(strConnectionString))
            {
                using (SqlCommand cmd = new SqlCommand(
                    "DELETE FROM [TBL_SONG] WHERE [ID_SONG] = @ID_SONG", con))
                {
                    cmd.Parameters.AddWithValue("@ID_SONG", idSong);
                    con.Open();
                    return cmd.ExecuteNonQuery();
                }
            }
        }
    }
}
