# ONYX — Product Requirements Document (PRD)
> ASP.NET Web Forms version for DDAC Group Assignment — Task 1 & Task 2  
> Version 1.4 | Reworked Web Forms codebase structure with page-attached C# code-behind

---

## 1. Project overview

ONYX is a single-tenant B2C gaming gear e-commerce web application. Users can browse, filter, and purchase gaming peripherals such as mouse, keyboard, headset, monitor, and gaming chair. The system has two roles: **customer** and **admin**.

This is a university cloud assignment. The application must be deployed on AWS and demonstrate a production-style architecture using EC2, Application Load Balancer, Auto Scaling Group, RDS PostgreSQL with read replica, S3, Lambda, API Gateway, SNS, SQS, CloudWatch, and X-Ray.

The application will be developed primarily as an **ASP.NET Web Forms application using .NET Framework and C# code-behind**. Each Web Forms page must be represented by an `.aspx` file, a connected `.aspx.cs` C# code-behind file, and an auto-generated `.aspx.designer.cs` file. Selected `.aspx` pages may embed compiled **React + TypeScript + Vite** widgets for specific interactive UI components, but Web Forms remains the main project structure.

---

## 2. Tech stack

| Layer | Technology |
|---|---|
| Web application framework | ASP.NET Web Forms |
| Backend language | C# |
| Runtime | .NET Framework 4.8 |
| UI rendering | Server-side `.aspx` pages with C# code-behind |
| Styling | CSS, Bootstrap optional, custom dark gaming theme |
| Client-side scripting | JavaScript / jQuery, with optional React + TypeScript widgets bundled using Vite |
| Data access | ADO.NET with Npgsql |
| Database | PostgreSQL 15 on AWS RDS |
| File storage | AWS S3 for product images and receipt files |
| Authentication | Forms Authentication + server-side Session |
| Hosting | IIS on Windows Server EC2 |
| Cloud services | AWS EC2, ALB, Auto Scaling, RDS, S3, Lambda, API Gateway, SNS, SQS, CloudWatch, X-Ray |

### Architecture decision

This PRD uses a **Web Forms-first monolithic structure**, not a full React single-page application and not a separate frontend/backend API architecture. The `.aspx` pages are the primary UI layer and are connected directly to `.aspx.cs` C# code-behind files.

React + TypeScript + Vite may be used only for selected embedded UI widgets such as product filters, cart quantity controls, image carousels, or admin dashboard charts. These React widgets must be compiled into JavaScript assets and loaded inside the relevant `.aspx` page. Do not design ONYX as a full React SPA with React Router, Axios API modules, or Zustand architecture.

---

## 3. Design system

- **Color scheme:** Black (`#0a0a0a`) background, toxic green (`#00ff87`) primary accent, white (`#ffffff`) text, dark gray (`#1a1a1a`) cards/surfaces
- **Font:** Inter or system sans-serif
- **Style:** Dark gaming aesthetic, high contrast, sharp component edges, subtle green hover glow
- **Layout:** Master page-based layout using `onyx_layout.Master` for customer pages and `admin.Master` for admin pages
- **Responsive:** Mobile-first using CSS media queries or Bootstrap grid
- **Brand placeholder:** If product image is missing, show a styled placeholder with `ONYX` or `OX`

---

## 4. Database schema (PostgreSQL)

Run this migration script on AWS RDS PostgreSQL:

```sql
CREATE TABLE users (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  fullname VARCHAR(100) NOT NULL,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  address TEXT,
  dob DATE,
  phone_number VARCHAR(30),
  role VARCHAR(20) NOT NULL DEFAULT 'customer',
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE products (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  brand VARCHAR(50),
  category VARCHAR(50) NOT NULL,
  description TEXT,
  price NUMERIC(10,2) NOT NULL,
  stock_qty INTEGER NOT NULL DEFAULT 0,
  image_url TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE product_variants (
  product_variant_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  product_id BIGINT NOT NULL,
  variant_type VARCHAR(50) NOT NULL,
  variant_value VARCHAR(100) NOT NULL,
  variant_price NUMERIC(10,2) NOT NULL,
  stock_qty INTEGER NOT NULL,
  image_url TEXT,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE orders (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'pending',
  total_amount NUMERIC(10,2) NOT NULL DEFAULT 0.00,
  shipping_address TEXT NOT NULL,
  receipt_s3_key TEXT,
  ordered_at TIMESTAMP NOT NULL DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE order_items (
  order_item_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  product_variant_id BIGINT,
  quantity INTEGER NOT NULL,
  unit_price NUMERIC(10,2) NOT NULL,
  subtotal NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
  FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id),
  FOREIGN KEY (product_variant_id) REFERENCES product_variants(product_variant_id)
);

CREATE TABLE reviews (
  review_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  rating SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE (user_id, product_id)
);

CREATE TABLE wishlists (
  wishlist_id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id BIGINT NOT NULL,
  product_id BIGINT NOT NULL,
  added_at TIMESTAMP NOT NULL DEFAULT now(),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (product_id) REFERENCES products(id),
  UNIQUE (user_id, product_id)
);
```

---

## 5. ASP.NET Web Forms project structure

The project must follow an **ASP.NET Web Application / Web Forms** structure like Visual Studio creates by default. The main C# logic for each page must stay attached to the page as `.aspx.cs`, and the `.aspx.designer.cs` files must remain auto-generated by Visual Studio.

Do **not** separate page code-behind into a shared folder. Page-level C# must remain beside its related `.aspx` page. Shared reusable classes should be placed in normal project folders such as `Models`, `DAL`, `Services`, and `Helpers`.

```text
ONYX/
├── ONYX.sln
└── ONYX.Web/
    ├── References/
    ├── Properties/
    ├── App_Data/
    │
    ├── customer_page/
    │   ├── onyx_layout.Master
    │   ├── onyx_layout.Master.cs
    │   ├── onyx_layout.Master.designer.cs
    │   ├── onyx_catalog.aspx
    │   ├── onyx_catalog.aspx.cs
    │   ├── onyx_catalog.aspx.designer.cs
    │   ├── onyx_products.aspx
    │   ├── onyx_products.aspx.cs
    │   ├── onyx_products.aspx.designer.cs
    │   ├── onyx_product_details.aspx
    │   ├── onyx_product_details.aspx.cs
    │   ├── onyx_product_details.aspx.designer.cs
    │   ├── onyx_cart.aspx
    │   ├── onyx_cart.aspx.cs
    │   ├── onyx_cart.aspx.designer.cs
    │   ├── onyx_checkout.aspx
    │   ├── onyx_checkout.aspx.cs
    │   ├── onyx_checkout.aspx.designer.cs
    │   ├── onyx_order_confirmation.aspx
    │   ├── onyx_order_confirmation.aspx.cs
    │   ├── onyx_order_confirmation.aspx.designer.cs
    │   ├── onyx_profile.aspx
    │   ├── onyx_profile.aspx.cs
    │   ├── onyx_profile.aspx.designer.cs
    │   ├── onyx_orders.aspx
    │   ├── onyx_orders.aspx.cs
    │   ├── onyx_orders.aspx.designer.cs
    │   ├── onyx_wishlist.aspx
    │   ├── onyx_wishlist.aspx.cs
    │   └── onyx_wishlist.aspx.designer.cs
    │
    ├── auth_page/
    │   ├── onyx_login.aspx
    │   ├── onyx_login.aspx.cs
    │   ├── onyx_login.aspx.designer.cs
    │   ├── onyx_register.aspx
    │   ├── onyx_register.aspx.cs
    │   └── onyx_register.aspx.designer.cs
    │
    ├── admin_page/
    │   ├── admin.Master
    │   ├── admin.Master.cs
    │   ├── admin.Master.designer.cs
    │   ├── onyx_admin_dashboard.aspx
    │   ├── onyx_admin_dashboard.aspx.cs
    │   ├── onyx_admin_dashboard.aspx.designer.cs
    │   ├── onyx_admin_products.aspx
    │   ├── onyx_admin_products.aspx.cs
    │   ├── onyx_admin_products.aspx.designer.cs
    │   ├── onyx_admin_product_form.aspx
    │   ├── onyx_admin_product_form.aspx.cs
    │   ├── onyx_admin_product_form.aspx.designer.cs
    │   ├── onyx_admin_orders.aspx
    │   ├── onyx_admin_orders.aspx.cs
    │   ├── onyx_admin_orders.aspx.designer.cs
    │   ├── onyx_admin_order_details.aspx
    │   ├── onyx_admin_order_details.aspx.cs
    │   ├── onyx_admin_order_details.aspx.designer.cs
    │   ├── onyx_admin_promos.aspx
    │   ├── onyx_admin_promos.aspx.cs
    │   ├── onyx_admin_promos.aspx.designer.cs
    │   ├── onyx_admin_users.aspx
    │   ├── onyx_admin_users.aspx.cs
    │   └── onyx_admin_users.aspx.designer.cs
    │
    ├── Models/
    │   ├── User.cs
    │   ├── Product.cs
    │   ├── ProductVariant.cs
    │   ├── Order.cs
    │   ├── OrderItem.cs
    │   ├── Review.cs
    │   ├── Wishlist.cs
    │   └── CartItem.cs
    │
    ├── DAL/
    │   ├── DbConnectionFactory.cs
    │   ├── UserRepository.cs
    │   ├── ProductRepository.cs
    │   ├── OrderRepository.cs
    │   ├── ReviewRepository.cs
    │   ├── WishlistRepository.cs
    │   └── AdminRepository.cs
    │
    ├── Services/
    │   ├── AuthService.cs
    │   ├── CartService.cs
    │   ├── ProductService.cs
    │   ├── OrderService.cs
    │   ├── S3Service.cs
    │   ├── LambdaService.cs
    │   └── ReceiptService.cs
    │
    ├── Helpers/
    │   ├── CurrencyHelper.cs
    │   ├── AuthHelper.cs
    │   └── ValidationHelper.cs
    │
    ├── Content/
    │   ├── site.css
    │   ├── admin.css
    │   └── responsive.css
    │
    ├── Scripts/
    │   ├── site.js
    │   └── validation.js
    │
    ├── ClientApp/                      # Optional React + TypeScript + Vite widgets only
    │   ├── package.json
    │   ├── vite.config.ts
    │   └── src/
    │       ├── productFilter.tsx
    │       ├── cartWidget.tsx
    │       └── adminChart.tsx
    │
    ├── dist/                           # Compiled Vite output loaded by selected .aspx pages
    ├── Images/
    │   └── placeholders/
    ├── Global.asax
    ├── Global.asax.cs
    ├── Web.config
    └── ONYX.Web.csproj
```

### Web Forms file relationship

Each Web Forms page must keep this relationship:

```text
onyx_products.aspx              → UI markup and Web Forms controls
onyx_products.aspx.cs           → page-specific C# code-behind logic
onyx_products.aspx.designer.cs  → auto-generated control declarations
```

Example page directive:

```aspx
<%@ Page Title="Products" Language="C#" MasterPageFile="~/customer_page/onyx_layout.Master"
    AutoEventWireup="true" CodeBehind="onyx_products.aspx.cs"
    Inherits="ONYX.Web.customer_page.onyx_products" %>
```

### Code-behind responsibility

The `.aspx.cs` file should handle page events and call service/repository classes. It should not contain all SQL or AWS logic directly.

Example responsibility split:

```text
onyx_products.aspx.cs
├── Page_Load()
├── BindProducts()
├── btnAddToCart_Click()
└── calls ProductService / CartService

ProductService.cs
└── business rules for products

ProductRepository.cs
└── SQL queries using Npgsql
```

### Optional React widget relationship

React must not replace the Web Forms page structure. When React is used, the `.aspx` page acts as the page shell and provides a mount point. Vite compiles the React + TypeScript source into JavaScript assets, and the `.aspx` page loads those compiled assets.

Example mount point inside an `.aspx` page:

```aspx
<div id="product-filter-root"></div>
<script type="module" src="/dist/assets/productFilter.js"></script>
```

The React component should handle only the interactive widget. Main page navigation, authentication checks, data loading from repositories, and order processing still belong to Web Forms code-behind, service classes, and repository classes.

---

## 6. Recommended NuGet packages

- `Npgsql`
- `AWSSDK.S3`
- `AWSSDK.Lambda`
- `AWSSDK.SimpleNotificationService`
- `AWSSDK.SQS`
- `BCrypt.Net-Next`
- `Newtonsoft.Json`
- `Microsoft.AspNet.FriendlyUrls` optional

---

## 7. Page specifications

### `onyx_catalog.aspx`

- Public catalogue/landing page for ONYX
- Hero section with headline: **Gear Up. Game On.**
- CTA buttons: **Shop Now** and **View Deals**
- Category cards: Mouse, Keyboard, Headset, Monitor, Chair
- Featured products loaded from `ProductService.GetFeaturedProducts(4)`
- Optional React widget may be embedded for dynamic catalogue filtering or featured product interaction
- Footer with logo, navigation links, and social icons

### `onyx_products.aspx`

- Public product listing page
- Filters:
  - Category dropdown or checkbox list
  - Brand dropdown or checkbox list
  - Minimum price and maximum price
  - Sort by newest, price low-high, price high-low, most reviewed
- Use `GridView`, `Repeater`, or custom server-rendered card layout
- Pagination: 12 products per page
- Each product card shows image, name, brand, price in MYR, rating, and Add to Cart button

### `onyx_product_details.aspx`

- Public product detail page using query string: `onyx_product_details.aspx?id=1`
- Displays product image, name, brand, category, price, stock status, description
- Variant selector using `DropDownList` or `RadioButtonList`
- Quantity selector
- Add to Cart button
- Add to Wishlist button for logged-in customers
- Review list and review form for logged-in customers

### `onyx_login.aspx`

- Login form with email and password
- Calls `AuthService.Login(email, password)`
- On successful login:
  - Store `Session["UserId"]`
  - Store `Session["Username"]`
  - Store `Session["Role"]`
  - Use Forms Authentication cookie
  - Redirect customer to `~/customer_page/onyx_catalog.aspx`
  - Redirect admin to `~/admin_page/onyx_admin_dashboard.aspx`

### `onyx_register.aspx`

- Registration form:
  - fullname
  - username
  - email
  - password
  - address
  - phone number
  - date of birth
- Password is hashed using BCrypt before being stored in the database
- Default role is `customer`

### `onyx_cart.aspx`

- Cart page using `Session["Cart"]`
- Displays cart line items:
  - product image
  - product name
  - selected variant
  - unit price
  - quantity
  - subtotal
- Customer can update quantity or remove item
- Shows subtotal, flat shipping fee RM10, and total amount
- Optional React widget may be embedded for quantity stepper or cart summary interactivity

### `onyx_checkout.aspx`

- Auth required
- Shipping address form pre-filled from user profile
- Order summary section
- Simulated payment section:
  - card number
  - expiry date
  - CVV
- No real payment gateway is required
- On Place Order:
  - Insert order into RDS PostgreSQL
  - Insert order items
  - Decrement stock through Lambda or service logic
  - Trigger API Gateway/Lambda workflow
  - Redirect to `onyx_order_confirmation.aspx?orderId={id}`

### `onyx_order_confirmation.aspx`

- Shows success message and order ID
- Shows order summary table
- Shows message: **A confirmation email has been sent**
- Shows receipt download link if `receipt_s3_key` exists
- Continue Shopping button redirects to `onyx_catalog.aspx`

### `onyx_profile.aspx`

- Auth required
- Customer can update fullname, address, phone number, and date of birth
- Optional change password form

### `onyx_orders.aspx`

- Auth required
- Shows customer order history only
- Columns:
  - order ID
  - date
  - status
  - total amount
  - view details button

### `onyx_wishlist.aspx`

- Auth required
- Shows saved products
- Customer can remove item from wishlist
- Customer can move product to cart

### `onyx_admin_dashboard.aspx`

- Admin only
- Uses `admin.Master`
- Shows metric cards:
  - total revenue
  - total orders
  - total users
  - low stock items
- Shows recent orders table
- Shows low stock product alert list
- Optional React widget may be embedded for charts only

### `onyx_admin_products.aspx`

- Admin only
- Searchable product management table
- Columns:
  - image thumbnail
  - name
  - category
  - price
  - stock quantity
  - edit button
  - delete button
- Add New Product button

### `onyx_admin_product_form.aspx`

- Admin only
- Used for both add and edit product
- Form fields:
  - name
  - brand
  - category
  - description
  - price
  - stock quantity
  - image upload
- Product images are uploaded to S3
- S3 URL is stored in `products.image_url`

### `onyx_admin_orders.aspx`

- Admin only
- Shows all orders
- Filter by status:
  - All
  - Pending
  - Shipped
  - Delivered
  - Cancelled
- Admin can update order status using a dropdown

### `onyx_admin_order_details.aspx`

- Admin only
- Shows complete order details:
  - customer information
  - shipping address
  - order items
  - total amount
  - receipt link

### `onyx_admin_promos.aspx`

- Admin only
- Manages promotion banners or promotional messages shown on catalogue pages
- Basic fields:
  - promo title
  - description
  - discount label
  - active/inactive status

### `onyx_admin_users.aspx`

- Admin only
- Shows all users
- Columns:
  - fullname
  - email
  - join date
  - total orders
  - total spent

---

## 8. Authentication and authorization rules

### Authentication method

ONYX uses ASP.NET Forms Authentication with server-side Session variables.

Required session values after login:

```csharp
Session["UserId"] = user.Id;
Session["Username"] = user.Username;
Session["Role"] = user.Role;
```

### Authorization rules

- Customer pages that require login must check `Session["UserId"] != null`
- Admin pages must check `Session["Role"] == "admin"`
- If a user is not logged in, redirect to `~/auth_page/onyx_login.aspx`
- If a customer attempts to access admin pages, redirect to `~/customer_page/onyx_catalog.aspx` or show an unauthorized page

### Master page authorization

`admin.Master.cs` should include an admin check in `Page_Load` so that every admin page is protected consistently.

---

## 9. Data access layer

Use ADO.NET with Npgsql for PostgreSQL connection and queries.

### `DbConnectionFactory.cs`

Purpose:
- Reads PostgreSQL connection string from `Web.config`
- Creates `NpgsqlConnection`
- Supports primary RDS connection and read replica connection

Connection string names:

```xml
<connectionStrings>
  <add name="DefaultConnection"
       connectionString="Host=&lt;RDS_ENDPOINT&gt;;Database=onyx;Username=postgres;Password=&lt;PASSWORD&gt;"
       providerName="Npgsql" />

  <add name="ReadConnection"
       connectionString="Host=&lt;RDS_REPLICA_ENDPOINT&gt;;Database=onyx;Username=postgres;Password=&lt;PASSWORD&gt;"
       providerName="Npgsql" />
</connectionStrings>
```

### Repository responsibilities

| Repository | Responsibility |
|---|---|
| `UserRepository.cs` | Register, login lookup, profile update, user listing |
| `ProductRepository.cs` | Product listing, filtering, sorting, details, variants, image URL update |
| `OrderRepository.cs` | Create order, order items, customer order history, admin order management |
| `ReviewRepository.cs` | Add review, list product reviews, enforce one review per user per product |
| `WishlistRepository.cs` | Add wishlist item, remove wishlist item, list wishlist products |
| `AdminRepository.cs` | Dashboard metrics, revenue, low stock products, user spending summary |

### Service responsibilities

| Service | Responsibility |
|---|---|
| `AuthService.cs` | Login, password verification, password hashing, session-safe user result |
| `CartService.cs` | Add to cart, update quantity, remove item, calculate subtotal and total |
| `ProductService.cs` | Product business rules, featured products, stock validation |
| `OrderService.cs` | Checkout workflow, order creation, stock handling, Lambda workflow trigger |
| `S3Service.cs` | Product image upload and receipt file access |
| `LambdaService.cs` | Calls API Gateway endpoints for serverless workflow |
| `ReceiptService.cs` | Receipt data formatting and receipt key generation |

---

## 10. AWS architecture (Task 1)

| Service | Purpose |
|---|---|
| EC2 Windows Server | Hosts ASP.NET Web Forms application through IIS |
| IIS | Serves `.aspx` pages and handles Web Forms runtime |
| Application Load Balancer | Distributes traffic across EC2 instances |
| Auto Scaling Group | Min 1, Max 3 EC2 instances, scale on CPU > 70% |
| RDS PostgreSQL `db.t3.micro` | Primary database for writes |
| RDS Read Replica | Read queries such as product listing and search |
| S3 bucket `onyx-assets` | Product images and receipt files |

### EC2/IIS setup

- Use Windows Server EC2 instance
- Install IIS
- Install .NET Framework 4.8 runtime
- Install ASP.NET feature for IIS
- Publish ONYX.Web from Visual Studio
- Deploy published files to IIS web root
- Configure IIS application pool for .NET Framework CLR
- Configure inbound security group rules for HTTP/HTTPS
- Store secrets in `Web.config` or environment variables

---

## 11. AWS serverless components (Task 2)

When a customer places an order from `onyx_checkout.aspx`, the Web Forms code-behind calls `OrderService.CreateOrder()`. After saving the order and order items to RDS, `LambdaService` calls API Gateway endpoints that trigger Lambda workflows.

### Lambda 1 — Order confirmation email

```text
Trigger: API Gateway POST /lambda/order-confirm
Input: { orderId, userEmail, userName, items, total }
Action: Publish to SNS topic and send confirmation email to customer
```

### Lambda 2 — Inventory update + low stock alert

```text
Trigger: API Gateway POST /lambda/inventory-update
Input: { items: [{ productId, quantity }] }
Action:
  1. Decrement stock_qty in RDS for each item
  2. If any product stock_qty < 5 after update, publish SNS alert to admin email
```

### Lambda 3 — Receipt generation

```text
Trigger: API Gateway POST /lambda/generate-receipt
Input: { orderId, userEmail, items, total, shippingAddress }
Action:
  1. Generate a JSON receipt object
  2. Save to S3 as receipts/{orderId}.json
  3. Update orders.receipt_s3_key in RDS
  4. Return presigned S3 URL valid for 7 days
```

### Lambda 4 — Order queue

```text
Trigger: API Gateway POST /lambda/queue-order
Input: { orderId, userId, items }
Action: Push message to SQS queue "onyx-orders"
Purpose: Queue order fulfilment work for admin/order processing workflow
```

### Monitoring

- CloudWatch metrics:
  - EC2 CPU utilisation
  - RDS connections
  - Lambda invocation count
  - Lambda errors
  - SQS queue depth
- X-Ray:
  - Trace Web Forms application calls to API Gateway and Lambda
- CloudWatch alarm:
  - EC2 CPU > 80% for 5 minutes triggers SNS alert to admin

---

## 12. Web.config configuration

```xml
<configuration>
  <connectionStrings>
    <add name="DefaultConnection"
         connectionString="Host=&lt;RDS_ENDPOINT&gt;;Database=onyx;Username=postgres;Password=&lt;PASSWORD&gt;"
         providerName="Npgsql" />
    <add name="ReadConnection"
         connectionString="Host=&lt;RDS_REPLICA_ENDPOINT&gt;;Database=onyx;Username=postgres;Password=&lt;PASSWORD&gt;"
         providerName="Npgsql" />
  </connectionStrings>

  <appSettings>
    <add key="AWSRegion" value="ap-southeast-1" />
    <add key="S3BucketName" value="onyx-assets" />
    <add key="ApiGatewayBaseUrl" value="&lt;API_GATEWAY_URL&gt;" />
    <add key="AdminEmail" value="admin@onyx.com" />
  </appSettings>

  <system.web>
    <compilation debug="true" targetFramework="4.8" />
    <httpRuntime targetFramework="4.8" />
    <authentication mode="Forms">
      <forms loginUrl="~/auth_page/onyx_login.aspx" timeout="10080" />
    </authentication>
    <sessionState mode="InProc" timeout="60" />
  </system.web>
</configuration>
```

---

## 13. Seed data

```sql
-- Admin user (password: Admin@123 — bcrypt hash)
INSERT INTO users (fullname, username, email, password_hash, role)
VALUES ('Admin', 'admin', 'admin@onyx.com',
'$2a$11$FYR4Rhbh92HnhCgO7qLhqesjfb.BJwLu.ZpwRVqEh4T4b/kyv.QAy', 'admin');

-- Sample products
INSERT INTO products (name, brand, category, price, stock_qty, description)
VALUES
('Viper V2 Pro', 'Razer', 'Mouse', 599.00, 23, 'Ultra-lightweight wireless gaming mouse'),
('BlackWidow V3', 'Razer', 'Keyboard', 449.00, 15, 'Mechanical gaming keyboard with Razer Green switches'),
('Kraken X', 'Razer', 'Headset', 299.00, 31, '7.1 surround sound gaming headset'),
('DeathAdder V3', 'Razer', 'Mouse', 349.00, 4, 'Ergonomic wired gaming mouse'),
('Huntsman Mini', 'Razer', 'Keyboard', 529.00, 10, '60% compact gaming keyboard'),
('Predator XB273U', 'Acer', 'Monitor', 1899.00, 8, '27-inch 165Hz IPS gaming monitor'),
('Secretlab Titan', 'Secretlab', 'Chair', 2199.00, 5, 'Ergonomic gaming chair with lumbar support'),
('G502 X Plus', 'Logitech', 'Mouse', 499.00, 18, 'HERO sensor wireless gaming mouse');
```

---

## 14. Key business rules

1. Only users with `role = 'admin'` can access pages inside `/admin_page/`.
2. Customers can only view their own orders.
3. Stock is decremented when an order is placed, not when it ships.
4. A product with `stock_qty = 0` must show **Out of Stock** and cannot be added to cart.
5. Reviews can only be submitted by logged-in users.
6. Each user can only submit one review per product.
7. Prices are always displayed in MYR format, for example `RM 299.00`.
8. Order status flow is `pending` → `shipped` → `delivered`; admin may also set `cancelled`.
9. Cart is stored in `Session["Cart"]` for this assignment.
10. Simulated payment accepts any card number; no real payment gateway is required.
11. Receipt S3 key format is `receipts/{orderId}.json`.
12. Admin product image upload must save the file to S3 and store the S3 URL in PostgreSQL.
13. Product listing should use the RDS read replica where possible.
14. Write operations such as register, checkout, review submission, and wishlist update must use the primary RDS database.

---

## 15. Acceptance criteria for Task 1

- [ ] User can register, login, and logout through Web Forms pages
- [ ] User can browse products with filter and sort
- [ ] User can view product detail with variants
- [ ] User can add products to cart and update quantities
- [ ] User can complete checkout and place an order
- [ ] User can view order history and order details
- [ ] User can add and remove wishlist items
- [ ] User can submit a product review
- [ ] Admin can add, edit, and delete products with image upload
- [ ] Admin can view and update order status
- [ ] Admin dashboard shows revenue, order count, users, and low stock items
- [ ] Application is deployed on EC2 Windows Server with IIS
- [ ] Database is hosted on AWS RDS PostgreSQL
- [ ] Product images are stored in S3
- [ ] Application uses an Application Load Balancer
- [ ] Auto Scaling Group is configured with min 1 and max 3 EC2 instances
- [ ] RDS read replica is used for product listing/read-heavy queries

---

## 16. Acceptance criteria for Task 2

- [ ] API Gateway + Lambda #1 sends SNS email when order is placed
- [ ] API Gateway + Lambda #2 decrements stock in RDS and sends low stock SNS alert
- [ ] API Gateway + Lambda #3 saves receipt to S3 and returns receipt URL
- [ ] API Gateway + Lambda #4 pushes order message to SQS queue
- [ ] CloudWatch dashboard shows EC2 CPU, RDS connections, Lambda metrics, and SQS queue depth
- [ ] X-Ray service map shows Web Forms application → API Gateway → Lambda trace
- [ ] CloudWatch alarm sends SNS alert when EC2 CPU is above threshold
- [ ] Admin can verify order workflow from Web Forms admin pages

---

## 17. Development notes for AI coding agents

- Generate ASP.NET Web Forms pages first; generate React components only when they are explicitly needed as embedded widgets.
- Every page must include `.aspx`, `.aspx.cs`, and `.aspx.designer.cs` files.
- Keep page-level C# inside the attached `.aspx.cs` file.
- Use C# code-behind events such as `Page_Load`, `btnLogin_Click`, `btnAddToCart_Click`, and `GridView_RowCommand`.
- Use `Session["UserId"]`, `Session["Username"]`, and `Session["Role"]` for user state.
- Use repository classes in `DAL/` for database operations.
- Use service classes in `Services/` for business logic and AWS integrations.
- Use model classes in `Models/` for data objects.
- Use helper classes in `Helpers/` for reusable formatting, validation, and authorization helpers.
- Use `onyx_layout.Master` for customer pages and `admin.Master` for admin pages.
- Do not generate a full React SPA, Axios API layer, React Router, or Zustand architecture.
- React + TypeScript + Vite can only be generated as optional embedded widgets under `ClientApp/`, then compiled into `dist/` and loaded by specific `.aspx` pages.
