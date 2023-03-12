-- IDEMPIERE-5623 Create Lines From in Shipment must show pending quantities
SELECT register_migration_script('202303091847_IDEMPIERE-5623.sql') FROM dual;

SET SQLBLANKLINES ON
SET DEFINE OFF

-- Mar 9, 2023, 6:47:01 PM CET
UPDATE AD_ViewColumn SET ColumnSQL='CASE o.issotrx WHEN ''Y'' THEN l.qtyordered-l.qtydelivered ELSE l.qtyordered - sum(COALESCE(m.qty, 0)) - COALESCE(( SELECT sum(iol.movementqty) AS sum FROM m_inoutline iol JOIN m_inout io ON iol.m_inout_id = io.m_inout_id WHERE l.c_orderline_id = iol.c_orderline_id AND io.processed = ''N''), 0) END',Updated=TO_TIMESTAMP('2023-03-09 18:47:01','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_ViewColumn_UU='33132bfe-bb61-4475-b646-7ad03d0fd8a4'
;

-- Mar 9, 2023, 6:47:08 PM CET
CREATE OR REPLACE VIEW M_InOut_CreateFrom_v(Qty, Multiplier, C_UOM_ID, M_Locator_ID, M_Product_ID, C_Charge_ID, VendorProductNo, Line, C_OrderLine_ID, C_InvoiceLine_ID, M_RMALine_ID, C_BPartner_ID, C_Order_ID, C_Invoice_ID, M_RMA_ID, M_InOut_CreateFrom_v_ID, AD_Client_ID, AD_Org_ID, IsActive, UPC, M_Warehouse_ID, IsSOTrx, AD_Table_ID) AS SELECT CASE o.issotrx WHEN 'Y' THEN l.qtyordered-l.qtydelivered ELSE l.qtyordered - sum(COALESCE(m.qty, 0)) - COALESCE(( SELECT sum(iol.movementqty) AS sum FROM m_inoutline iol JOIN m_inout io ON iol.m_inout_id = io.m_inout_id WHERE l.c_orderline_id = iol.c_orderline_id AND io.processed = 'N'), 0) END AS Qty, CASE WHEN l.qtyordered = 0 THEN 0 ELSE l.qtyentered / l.qtyordered END AS Multiplier, l.c_uom_id AS C_UOM_ID, p.m_locator_id AS M_Locator_ID, COALESCE(l.m_product_id, 0) AS M_Product_ID, COALESCE(l.c_charge_id, 0) AS C_Charge_ID, po.vendorproductno AS VendorProductNo, l.line AS Line, l.c_orderline_id AS C_OrderLine_ID, 0 AS C_InvoiceLine_ID, 0 AS M_RMALine_ID, l.c_bpartner_id AS C_BPartner_ID, l.c_order_id AS C_Order_ID, 0 AS C_Invoice_ID, 0 AS M_RMA_ID, l.c_orderline_id AS M_InOut_CreateFrom_v_ID, l.ad_client_id AS AD_Client_ID, l.ad_org_id AS AD_Org_ID, l.isactive AS IsActive, p.upc AS UPC, o.m_warehouse_id AS M_Warehouse_ID, o.issotrx AS IsSOTrx, 260 AS AD_Table_ID FROM c_orderline l
     JOIN c_order o ON o.c_order_id = l.c_order_id
     LEFT JOIN m_product_po po ON l.m_product_id = po.m_product_id AND l.c_bpartner_id = po.c_bpartner_id
     LEFT JOIN m_matchpo m ON l.c_orderline_id = m.c_orderline_id AND m.m_inoutline_id IS NOT NULL
     LEFT JOIN m_product p ON l.m_product_id = p.m_product_id GROUP BY l.qtyordered, (
        CASE
            WHEN l.qtyordered = 0 THEN 0
            ELSE l.qtyentered / l.qtyordered
        END), 
l.c_uom_id, p.m_locator_id, po.vendorproductno, l.m_product_id, l.c_charge_id, l.line, l.c_orderline_id, p.upc,o.m_warehouse_id,o.issotrx, 
l.c_bpartner_id,l.c_order_id,l.ad_client_id,l.ad_org_id,l.IsActive UNION  ALL SELECT l.qtyinvoiced - sum(nvl(mi.qty, 0)) AS Qty, l.qtyentered / l.qtyinvoiced AS Multiplier, l.c_uom_id AS C_UOM_ID, p.m_locator_id AS M_Locator_ID, l.m_product_id AS M_Product_ID, l.c_charge_id AS C_Charge_ID, po.vendorproductno AS VendorProductNo, l.line AS Line, l.c_orderline_id AS C_OrderLine_ID, l.c_invoiceline_id AS C_InvoiceLine_ID, 0 AS M_RMALine_ID, inv.c_bpartner_id AS C_BPartner_ID, 0 AS C_Order_ID, l.c_invoice_id AS C_Invoice_ID, 0 AS M_RMA_ID, l.c_invoiceline_id AS M_InOut_CreateFrom_v_ID, l.ad_client_id AS AD_Client_ID, l.ad_org_id AS AD_Org_ID, l.isactive AS IsActive, p.upc AS UPC, 0 AS M_Warehouse_ID, inv.issotrx AS IsSOTrx, 333 AS AD_Table_ID FROM c_invoiceline l
     LEFT JOIN m_product p ON l.m_product_id = p.m_product_id
     JOIN c_invoice inv ON l.c_invoice_id = inv.c_invoice_id
     LEFT JOIN m_product_po po ON l.m_product_id = po.m_product_id AND inv.c_bpartner_id = po.c_bpartner_id
     LEFT JOIN m_matchinv mi ON l.c_invoiceline_id = mi.c_invoiceline_id WHERE l.qtyinvoiced <> 0 GROUP BY l.qtyinvoiced, (l.qtyentered / l.qtyinvoiced), l.c_uom_id, p.m_locator_id, l.m_product_id, l.c_charge_id, po.vendorproductno, l.c_invoiceline_id, l.line, l.c_orderline_id, inv.c_bpartner_id, l.c_invoice_id, p.upc, inv.issotrx, l.ad_client_id,l.ad_org_id,l.IsActive UNION  ALL SELECT rl.qty - rl.qtydelivered AS Qty, 1 AS Multiplier, uom.c_uom_id AS C_UOM_ID, p.m_locator_id AS M_Locator_ID, p.m_product_id AS M_Product_ID, c.c_charge_id AS C_Charge_ID, po.vendorproductno AS VendorProductNo, rl.line AS Line, 0 AS C_OrderLine_ID, 0 AS C_InvoiceLine_ID, rl.m_rmaline_id AS M_RMALine_ID, r.c_bpartner_id AS C_BPartner_ID, 0 AS C_Order_ID, 0 AS C_Invoice_ID, r.m_rma_id AS M_RMA_ID, rl.m_rmaline_id AS M_InOut_CreateFrom_v_ID, rl.ad_client_id AS AD_Client_ID, rl.ad_org_id AS AD_Org_ID, rl.isactive AS IsActive, p.upc AS UPC, 0 AS M_Warehouse_ID, r.issotrx AS IsSOTrx, 660 AS AD_Table_ID FROM m_rmaline rl
     JOIN m_rma r ON r.m_rma_id = rl.m_rma_id
     JOIN m_inoutline iol ON rl.m_inoutline_id = iol.m_inoutline_id
     LEFT JOIN m_product p ON p.m_product_id = iol.m_product_id
     LEFT JOIN c_uom uom ON uom.c_uom_id = COALESCE(p.c_uom_id, iol.c_uom_id)
     LEFT JOIN c_charge c ON c.c_charge_id = iol.c_charge_id
     LEFT JOIN m_product_po po ON rl.m_product_id = po.m_product_id AND r.c_bpartner_id = po.c_bpartner_id WHERE rl.m_inoutline_id IS NOT NULL UNION  ALL SELECT rl.qty - rl.qtydelivered AS Qty, 1 AS Multiplier, uom.c_uom_id AS C_UOM_ID, p.m_locator_id AS M_Locator_ID, p.m_product_id AS M_Product_ID, 0 AS C_Charge_ID, po.vendorproductno AS VendorProductNo, rl.line AS Line, 0 AS C_OrderLine_ID, 0 AS C_InvoiceLine_ID, rl.m_rmaline_id AS M_RMALine_ID, r.c_bpartner_id AS C_BPartner_ID, 0 AS C_Order_ID, 0 AS C_Invoice_ID, r.m_rma_id AS M_RMA_ID, rl.m_rmaline_id AS M_InOut_CreateFrom_v_ID, rl.ad_client_id AS AD_Client_ID, rl.ad_org_id AS AD_Org_ID, rl.isactive AS IsActive, p.upc AS UPC, 0 AS M_Warehouse_ID, r.issotrx AS IsSOTrx, 660 AS AD_Table_ID FROM m_rmaline rl
     JOIN m_rma r ON r.m_rma_id = rl.m_rma_id
     JOIN m_product p ON p.m_product_id = rl.m_product_id
     LEFT JOIN c_uom uom ON uom.c_uom_id = p.c_uom_id
     LEFT JOIN m_product_po po ON rl.m_product_id = po.m_product_id AND r.c_bpartner_id = po.c_bpartner_id WHERE rl.m_product_id IS NOT NULL AND rl.m_inoutline_id IS NULL UNION  ALL SELECT rl.qty - rl.qtydelivered AS Qty, 1 AS Multiplier, uom.c_uom_id AS C_UOM_ID, 0 AS M_Locator_ID, 0 AS M_Product_ID, c.c_charge_id AS C_Charge_ID, NULL AS VendorProductNo, rl.line AS Line, 0 AS C_OrderLine_ID, 0 AS C_InvoiceLine_ID, rl.m_rmaline_id AS M_RMALine_ID, r.c_bpartner_id AS C_BPartner_ID, 0 AS C_Order_ID, 0 AS C_Invoice_ID, r.m_rma_id AS M_RMA_ID, rl.m_rmaline_id AS M_InOut_CreateFrom_v_ID, rl.ad_client_id AS AD_Client_ID, rl.ad_org_id AS AD_Org_ID, rl.isactive AS IsActive, NULL AS UPC, 0 AS M_Warehouse_ID, r.issotrx AS IsSOTrx, 660 AS AD_Table_ID FROM m_rmaline rl
     JOIN m_rma r ON r.m_rma_id = rl.m_rma_id
     JOIN c_charge c ON c.c_charge_id = rl.c_charge_id
     LEFT JOIN c_uom uom ON uom.c_uom_id = 100 WHERE rl.c_charge_id IS NOT NULL AND rl.m_inoutline_id IS NULL
;

