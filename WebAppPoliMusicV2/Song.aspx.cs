using System;
using System.Configuration;
using System.Data;
using System.Text;
using System.Web;

namespace WebAppPoliMusicV2
{
    public partial class Song : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!Page.IsPostBack)
            {
                LoadUser();
                LoadSongs();
            }
        }

        private void LoadUser()
        {
            Entities.User user = Session[Util.Constants.USER] as Entities.User;
            string userName = user == null || string.IsNullOrEmpty(user.UserName) ? "amigo" : user.UserName;
            litUserName.Text = HttpUtility.HtmlEncode(userName);
            litProfileName.Text = HttpUtility.HtmlEncode(userName);

            string photo = user == null ? string.Empty : user.Photo;
            imgUser.ImageUrl = ResolveUrl(string.IsNullOrEmpty(photo) ? "~/UserImages/default.jpg" : photo);
        }

        private void LoadSongs()
        {
            string connectionString = ConfigurationManager.ConnectionStrings["BDD_PoliMusicConnectionString"].ConnectionString;
            DataTable songs = new BLL.Song(connectionString).Read();
            litSongCount.Text = songs.Rows.Count.ToString();

            if (songs.Rows.Count == 0)
            {
                litSongs.Text = "<p class=\"empty\">Aún no hay canciones en tu biblioteca.</p>";
                return;
            }

            StringBuilder markup = new StringBuilder();
            int position = 1;
            foreach (DataRow row in songs.Rows)
            {
                string title = Convert.ToString(row["SONG_NAME"]);
                string path = Convert.ToString(row["SONG_PATH"]);
                string safeTitle = HttpUtility.HtmlEncode(title);
                string safeSearchTitle = HttpUtility.HtmlAttributeEncode(title.ToLowerInvariant());
                string safePath = HttpUtility.HtmlAttributeEncode(ResolveUrl(path));
                string plays = Convert.ToString(row["PLAYS"]);

                markup.Append("<article class=\"song-card\" data-title=\"");
                markup.Append(safeSearchTitle);
                markup.Append("\">");
                markup.Append("<span class=\"song-index\">");
                markup.Append(position++);
                markup.Append("</span>");
                markup.Append("<img class=\"cover\" src=\"");
                markup.Append(ResolveUrl("~/PlaylistImages/default.jpg"));
                markup.Append("\" alt=\"\" />");
                markup.Append("<div><p class=\"song-title\">");
                markup.Append(safeTitle);
                markup.Append("</p><span class=\"song-meta\">PoliMusic library</span></div>");
                markup.Append("<div class=\"audio-wrap\"><audio controls preload=\"none\" src=\"");
                markup.Append(safePath);
                markup.Append("\">Tu navegador no admite audio HTML5.</audio></div>");
                markup.Append("<div class=\"plays\"><strong>");
                markup.Append(HttpUtility.HtmlEncode(plays));
                markup.Append("</strong>plays</div></article>");
            }
            litSongs.Text = markup.ToString();
        }
    }
}
