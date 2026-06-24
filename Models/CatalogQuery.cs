namespace ONYX_DDAC.Models
{
    public class CatalogQuery
    {
        public string Category { get; set; }
        public string SearchTerm { get; set; }
        public string Sort { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
    }
}
