using System.Collections.Generic;
using ONYX_DDAC.DAL;
using ONYX_DDAC.Models;

namespace ONYX_DDAC.Services
{
    public class UserService
    {
        private readonly UserRepository _repo;

        public UserService() : this(new UserRepository()) { }

        public UserService(UserRepository repo)
        {
            _repo = repo;
        }

        // ── Admin: user list ─────────────────────────────────────────────────
        public List<UserSummary> GetAllUsers()
        {
            return _repo.GetAllUsers();
        }

        public UserStats GetStats()
        {
            return _repo.GetStats();
        }

        // ── Admin: user detail ───────────────────────────────────────────────
        public UserDetail GetUserById(long id)
        {
            return _repo.GetUserById(id);
        }

        public List<UserOrderSummary> GetUserOrders(long userId)
        {
            return _repo.GetUserOrders(userId);
        }

        // Validates and updates a user record.
        // Returns error string or null on success.
        public string UpdateUser(long id, string fullName, string email,
            string phone, string address, string role)
        {
            if (string.IsNullOrWhiteSpace(fullName))
                return "Full name is required.";
            if (string.IsNullOrWhiteSpace(email))
                return "Email is required.";

            var allowedRoles = new[] { "admin", "customer" };
            bool validRole = false;
            foreach (var r in allowedRoles) if (r == role) { validRole = true; break; }
            if (!validRole) return "Invalid role.";

            _repo.UpdateUser(id, fullName, email, phone, address, role);
            return null;
        }

        public void DeleteUser(long id)
        {
            _repo.DeleteUser(id);
        }

        // ── Admin settings ───────────────────────────────────────────────────
        public List<UserSummary> GetAdminList()
        {
            return _repo.GetAdminList();
        }
    }
}
