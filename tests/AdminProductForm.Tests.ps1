$root = Split-Path $PSScriptRoot -Parent
$markupPath = "$root\admin_page\onyx_admin_products_form.aspx"
$codePath = "$root\admin_page\onyx_admin_products_form.aspx.cs"
$designerPath = "$root\admin_page\onyx_admin_products_form.aspx.designer.cs"
$servicePath = "$root\Services\ProductService.cs"
$repoPath = "$root\DAL\ProductRepository.cs"
$webConfigPath = "$root\Web.config"
$migrationPath = "$root\App_Data\20260709_product_images_rds.sql"
$campaignMigrationPath = "$root\App_Data\20260709_product_campaigns.sql"
$campaignBlocksMigrationPath = "$root\App_Data\20260709_product_campaign_blocks.sql"
$modelPath = "$root\Models\ProductImage.cs"
$campaignModelPath = "$root\Models\ProductCampaign.cs"
$campaignBlockModelPath = "$root\Models\ProductCampaignBlock.cs"
$detailsMarkupPath = "$root\customer_page\onyx_product_details.aspx"
$detailsCodePath = "$root\customer_page\onyx_product_details.aspx.cs"
$catalogMarkupPath = "$root\customer_page\onyx_catalog.aspx"
$catalogCodePath = "$root\customer_page\onyx_catalog.aspx.cs"
$adminProductsMarkupPath = "$root\admin_page\onyx_admin_products.aspx"
$adminProductsCodePath = "$root\admin_page\onyx_admin_products.aspx.cs"
$productModelPath = "$root\Models\Product.cs"
$catalogCssPath = "$root\Content\onyx-catalog.css"
$commerceCssPath = "$root\Content\onyx-commerce.css"

$markup = Get-Content $markupPath -Raw
$code = Get-Content $codePath -Raw
$designer = Get-Content $designerPath -Raw
$service = Get-Content $servicePath -Raw
$repo = Get-Content $repoPath -Raw
$webConfig = Get-Content $webConfigPath -Raw
$migration = if (Test-Path $migrationPath) { Get-Content $migrationPath -Raw } else { '' }
$campaignMigration = if (Test-Path $campaignMigrationPath) { Get-Content $campaignMigrationPath -Raw } else { '' }
$campaignBlocksMigration = if (Test-Path $campaignBlocksMigrationPath) { Get-Content $campaignBlocksMigrationPath -Raw } else { '' }
$model = if (Test-Path $modelPath) { Get-Content $modelPath -Raw } else { '' }
$campaignModel = if (Test-Path $campaignModelPath) { Get-Content $campaignModelPath -Raw } else { '' }
$campaignBlockModel = if (Test-Path $campaignBlockModelPath) { Get-Content $campaignBlockModelPath -Raw } else { '' }
$detailsMarkup = Get-Content $detailsMarkupPath -Raw
$detailsCode = Get-Content $detailsCodePath -Raw
$catalogMarkup = Get-Content $catalogMarkupPath -Raw
$catalogCode = Get-Content $catalogCodePath -Raw
$adminProductsMarkup = Get-Content $adminProductsMarkupPath -Raw
$adminProductsCode = Get-Content $adminProductsCodePath -Raw
$productModel = Get-Content $productModelPath -Raw
$catalogCss = Get-Content $catalogCssPath -Raw
$commerceCss = Get-Content $commerceCssPath -Raw
$deleteVisibilityIndex = $code.IndexOf('btnDelete.Visible = IsEditMode')
$editIdLoadIndex = $code.IndexOf('_EditId = id')

$checks = [ordered]@{
    'Admin product form offers restricted image upload' =
        $markup -match 'ProductImageUpload' -and
        $markup -match 'AllowMultiple="true"' -and
        $markup -match 'accept="\.jpg,\.jpeg,\.png,\.webp,image/jpeg,image/png,image/webp"' -and
        $designer -match 'FileUpload\s+ProductImageUpload' -and
        $code -match 'SaveUploadedProductImages' -and
        $code -match '\.jpg' -and
        $code -match '\.jpeg' -and
        $code -match '\.png' -and
        $code -match '\.webp' -and
        $code -match 'MaxProductImageBytes'

    'Admin product form locks brand to ONYX' =
        $markup -match 'Text="ONYX"' -and
        $markup -match 'ReadOnly="true"' -and
        $code -match 'const string LockedBrand = "ONYX"' -and
        $code -match 'string brand\s*=\s*LockedBrand'

    'Admin product form exposes expanded ONYX categories' =
        $markup -match 'Value="Mic"' -and
        $markup -match 'Value="Monitor Extension"' -and
        $markup -match 'Value="Accessory"' -and
        $markup -match 'Value="Mousepad"' -and
        $markup -match 'Value="Cable"'

    'Admin product form supports color choices while creating products' =
        $markup -match 'CreateColorChoices' -and
        $designer -match 'CheckBoxList\s+CreateColorChoices' -and
        $code -match 'BindCreateColorChoices' -and
        $code -match 'CreateColorVariantsForNewProduct' -and
        $code -match 'GetSelectedCreateColors'

    'New product save appends color variants after product creation' =
        $code -match 'long newId = _svc\.CreateProduct' -and
        $code -match 'CreateColorVariantsForNewProduct\s*\(\s*newId\s*,\s*price\s*,\s*stock\s*\)' -and
        $code -match '_svc\.AddVariant\s*\(\s*productId\s*,\s*"Color"'

    'Admin product form exposes multi-image manager controls' =
        $markup -match 'product-image-manager' -and
        $markup -match 'Upload multiple product photos\. Drag to reorder\. The first image will be used as the main product image\.' -and
        $markup -match 'ProductImageOrder' -and
        $markup -match 'RemovedProductImages' -and
        $markup -match 'Move left' -and
        $markup -match 'Move right' -and
        $markup -match 'Primary'

    'Admin product form validates image uploads before submit without base64 payloads' =
        $markup -match 'validateProductImagesBeforeSubmit' -and
        $markup -match 'MaxProductImageBytes' -and
        $markup -match 'MaxProductUploadBytes' -and
        $markup -match 'Only JPG, JPEG, PNG, and WEBP files up to 5 MB each are accepted\.' -and
        $markup -match 'URL\.createObjectURL' -and
        $markup -notmatch 'readAsDataURL' -and
        $markup -notmatch 'data:image/(jpeg|jpg|png|webp);base64'

    'Product image upload persists ordered gallery in product_images' =
        $model -match 'class ProductImage' -and
        $migration -match 'CREATE TABLE IF NOT EXISTS public\.product_images' -and
        $migration -match 'display_order INTEGER NOT NULL DEFAULT 0' -and
        $migration -match 'is_primary BOOLEAN NOT NULL DEFAULT false' -and
        $migration -match 'INSERT INTO public\.product_images' -and
        $repo -match 'FROM product_images' -and
        $repo -match 'INSERT INTO product_images' -and
        $repo -match 'DELETE FROM product_images' -and
        $repo -match 'UPDATE products SET image_url' -and
        $service -match 'GetProductImages' -and
        $service -match 'SaveProductImages' -and
        $code -match 'EnsureProductImageRows'

    'Admin product edit form supports deleting products' =
        $markup -match 'ID="btnDelete"' -and
        $markup -match 'Text="Delete Product"' -and
        $markup -match 'OnClick="btnDelete_Click"' -and
        $markup -match 'confirm\(''Delete this product\?' -and
        $designer -match 'Button\s+btnDelete' -and
        $code -match 'btnDelete\.Visible\s*=\s*IsEditMode' -and
        $deleteVisibilityIndex -gt $editIdLoadIndex -and
        $code -match 'btnDelete_Click' -and
        $code -match '_svc\.DeleteProduct\(_EditId\)' -and
        $service -match 'DeleteProduct\(long id\)' -and
        $repo -match 'DELETE FROM products WHERE id = @ProductId'

    'Web config supports 50MB product image upload requests' =
        $webConfig -match '<httpRuntime[^>]*maxRequestLength="51200"[^>]*executionTimeout="300"[^>]*/>' -and
        $webConfig -match '<system\.webServer>' -and
        $webConfig -match '<requestLimits maxAllowedContentLength="52428800" />'

    'Product campaigns have per-product database storage' =
        $campaignModel -match 'class ProductCampaign' -and
        $campaignModel -match 'CampaignEnabled' -and
        $campaignModel -match 'FeatureCards' -and
        $campaignMigration -match 'CREATE TABLE IF NOT EXISTS public\.product_campaigns' -and
        $campaignMigration -match 'product_id BIGINT PRIMARY KEY REFERENCES public\.products\(id\) ON DELETE CASCADE' -and
        $campaignMigration -match 'campaign_enabled BOOLEAN NOT NULL DEFAULT false' -and
        $campaignMigration -match 'feature_cards TEXT' -and
        $repo -match 'GetProductCampaign' -and
        $repo -match 'SaveProductCampaign' -and
        $repo -match 'INSERT INTO product_campaigns'

    'Admin product form captures product campaign content' =
        $markup -match 'ID="chkCampaignEnabled"' -and
        $designer -match 'CheckBox\s+chkCampaignEnabled' -and
        $code -match 'LoadCampaign' -and
        $code -match 'BuildCampaignFromForm' -and
        $code -match '_svc\.SaveProductCampaign' -and
        $markup -notmatch 'txtCampaignHeroEyebrow|txtCampaignHeroHeadline|txtCampaignFeatureCards|txtCampaignSpecsText|Legacy campaign fallback fields' -and
        $designer -notmatch 'txtCampaignHeroEyebrow|txtCampaignHeroHeadline|txtCampaignFeatureCards|txtCampaignSpecsText'

    'Product details renders enabled campaign blocks from product data' =
        $detailsMarkup -match 'litCampaignBlocks' -and
        $detailsCode -match 'GetProductCampaign' -and
        $detailsCode -match 'BindProductCampaign' -and
        $detailsCode -match 'GetCampaignBlocksByProductId' -and
        $detailsCode -notmatch 'productId == 2 \|\| productId == 3'

    'Product campaign blocks are repeatable per product and ordered only by sort order' =
        $campaignBlockModel -match 'class ProductCampaignBlock' -and
        $campaignBlockModel -match 'BlockType' -and
        $campaignBlockModel -match 'SortOrder' -and
        $campaignBlockModel -match 'JsonContent' -and
        $campaignBlocksMigration -match 'CREATE TABLE IF NOT EXISTS public\.product_campaign_blocks' -and
        $campaignBlocksMigration -match 'product_id BIGINT NOT NULL REFERENCES public\.products\(id\) ON DELETE CASCADE' -and
        $campaignBlocksMigration -match 'block_type VARCHAR\(50\) NOT NULL' -and
        $campaignBlocksMigration -match 'sort_order INTEGER NOT NULL' -and
        $campaignBlocksMigration -match 'ix_product_campaign_blocks_product_sort' -and
        $campaignBlocksMigration -notmatch 'UNIQUE\s*\(\s*product_id\s*,\s*block_type\s*\)' -and
        $campaignBlocksMigration -notmatch 'product_id,\s*block_type' -and
        $repo -match 'GetCampaignBlocksByProductId' -and
        $repo -match 'AddCampaignBlock[\s\S]*EnsureProductCampaignBlocksTable\(conn\)[\s\S]*ExecuteScalar' -and
        $repo -match 'public\.product_campaign_blocks' -and
        $repo -match 'ORDER BY sort_order ASC, id ASC' -and
        $repo -match 'AddCampaignBlock' -and
        $repo -match 'MoveCampaignBlockUp' -and
        $repo -match 'MoveCampaignBlockDown' -and
        $repo -match 'EnsureSortOrderIntegrity' -and
        $repo -notmatch 'COUNT\(\*\).*block_type' -and
        $service -match 'GetCampaignBlocksByProductId' -and
        $service -match 'AddCampaignBlock' -and
        $service -match 'MoveCampaignBlockUp' -and
        $service -match 'MoveCampaignBlockDown'

    'Admin product form exposes repeatable Product Campaign Builder controls' =
        $markup -match 'Product Campaign Builder' -and
        $markup -match 'ddlCampaignBlockType' -and
        $markup -match 'btnAddCampaignBlock' -and
        $markup -match 'rptCampaignBlocks' -and
        $markup -match 'data-campaign-block' -and
        $markup -match 'data-block-type' -and
        $markup -match 'campaign-field--media' -and
        $markup -match 'CampaignBlockMediaUpload' -and
        $markup -match 'Remove media' -and
        $markup -notmatch 'EmptyDataTemplate' -and
        $markup -match 'pnlCampaignBlocksEmpty' -and
        $markup -match 'CommandName="MoveUp"' -and
        $markup -match 'CommandName="MoveDown"' -and
        $markup -match 'CommandName="DeleteBlock"' -and
        $markup -match 'HeroMedia' -and
        $markup -match 'TextImageSection' -and
        $markup -match 'FeatureCards' -and
        $markup -match 'TechSpecs' -and
        $designer -match 'DropDownList\s+ddlCampaignBlockType' -and
        $designer -match 'Button\s+btnAddCampaignBlock' -and
        $designer -match 'Repeater\s+rptCampaignBlocks' -and
        $designer -match 'Panel\s+pnlCampaignBlocksEmpty' -and
        $code -match 'btnAddCampaignBlock_Click' -and
        $code -match 'rptCampaignBlocks_ItemCommand' -and
        $code -match 'PendingCampaignBlocks' -and
        $code -match 'PersistPendingCampaignBlocks' -and
        $code -notmatch 'Save the product before adding campaign blocks' -and
        $code -notmatch 'FirstOrDefault\s*\([^)]*BlockType|Any\s*\([^)]*BlockType|Count\s*\([^)]*BlockType' -and
        $code -notmatch 'duplicate block'

    'Customer product details renders enabled campaign blocks dynamically without legacy fallback' =
        $detailsMarkup -match 'litCampaignBlocks' -and
        $detailsMarkup -notmatch 'pnlLegacyCampaign|litCampaignHeroEyebrow|rptCampaignFeatures|rptCampaignSpecs' -and
        $detailsCode -match 'GetCampaignBlocksByProductId' -and
        $detailsCode -match 'RenderCampaignBlocks' -and
        $detailsCode -match 'RenderHeroMediaBlock' -and
        $detailsCode -match 'RenderFeatureCardsBlock' -and
        $detailsCode -match 'RenderTechSpecsBlock' -and
        $detailsCode -notmatch 'RenderLegacyCampaign|HasLegacyCampaignContent|ParseFeatureCards\(string rawValue, Product product\)' -and
        $detailsCode -match 'ORDER BY sort_order ASC, id ASC|GetCampaignBlocksByProductId' -and
        $detailsCode -notmatch 'product\.Id == 2|productId == 2|product\.Id == 3|productId == 3'

    'HeroMedia campaign block uses centered black ONYX layout' =
        $detailsCode -match 'onyx-campaign-hero' -and
        $detailsCode -match 'onyx-campaign-hero-text' -and
        $commerceCss -match '\.onyx-details-page\.onyx-keyboard-campaign \.onyx-campaign\s*\{[\s\S]*background:\s*#050505' -and
        $commerceCss -match '\.onyx-campaign-block\s*\{[\s\S]*background:\s*#050505' -and
        $commerceCss -match '\.onyx-campaign-hero\s*\{[\s\S]*display:\s*flex[\s\S]*flex-direction:\s*column[\s\S]*text-align:\s*center' -and
        $commerceCss -match '\.onyx-campaign-hero-text\s*\{[\s\S]*margin-left:\s*auto[\s\S]*margin-right:\s*auto' -and
        $commerceCss -notmatch '\.onyx-campaign-block--light\s*\{[\s\S]*background:\s*#f7f8fa'

    'Product cards expose multiple product photos with arrow navigation' =
        $productModel -match 'IList<string>\s+ImageUrls' -and
        $repo -match 'HydrateProductImageUrls' -and
        $repo -match 'product_images' -and
        $catalogMarkup -match 'onyx-product-gallery' -and
        $catalogMarkup -match 'data-gallery-next' -and
        $catalogCode -match 'GetProductGalleryHtml' -and
        $adminProductsMarkup -match 'admin-product-gallery' -and
        $adminProductsMarkup -match 'data-gallery-next' -and
        $adminProductsCode -match 'GetProductGalleryHtml'

    'Product thumbnails use admin detail square cover treatment' =
        $adminProductsMarkup -match 'aspect-ratio:\s*1\s*/\s*1' -and
        $adminProductsMarkup -match 'object-fit:\s*cover' -and
        $adminProductsMarkup -notmatch 'height:\s*185px' -and
        $catalogCss -match '\.onyx-product-media\s*\{[\s\S]*aspect-ratio:\s*1\s*/\s*1' -and
        $catalogCss -match '\.onyx-product-media img\s*\{[\s\S]*width:\s*100%' -and
        $catalogCss -match '\.onyx-product-media img\s*\{[\s\S]*object-fit:\s*cover' -and
        $catalogCss -match '\.onyx-catalog-page \.onyx-product-media\s*\{[\s\S]*aspect-ratio:\s*1\s*/\s*1'
}

$failures = @($checks.GetEnumerator() | Where-Object { -not $_.Value })
if ($failures.Count -gt 0) {
    throw ('Missing admin product form requirements: ' + (($failures | ForEach-Object Key) -join ', '))
}

Write-Output 'Admin product form source contract passes.'
