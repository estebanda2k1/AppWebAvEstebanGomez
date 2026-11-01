using System.Data;

namespace WebAppPoliMusicV2.BLL
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
            return new DAL.Song(strConnectionString).Read();
        }

        public DataTable GetById(int idSong)
        {
            return new DAL.Song(strConnectionString).GetById(idSong);
        }

        public int Save(string songName, string songPath, int plays)
        {
            return new DAL.Song(strConnectionString).Save(songName, songPath, plays);
        }

        public int Update(int idSong, string songName, string songPath, int plays)
        {
            return new DAL.Song(strConnectionString).Update(idSong, songName, songPath, plays);
        }

        public int Delete(int idSong)
        {
            return new DAL.Song(strConnectionString).Delete(idSong);
        }
    }
}
