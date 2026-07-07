namespace ONYX_DDAC.Models
{
    using System.Collections.Generic;

    public class CatalogQuery
    {
        public string Category { get; set; }
        public string SearchTerm { get; set; }
        public string Sort { get; set; }
        public int Page { get; set; }
        public int PageSize { get; set; }
        public long? UserId { get; set; }
        public IList<string> CurrentSearchSignals { get; set; }
    }
}
