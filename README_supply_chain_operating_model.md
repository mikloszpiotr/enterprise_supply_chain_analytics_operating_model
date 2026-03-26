# Enterprise Supply Chain Analytics Operating Model

SQL-Based Decision Platform for Inventory, Service, Supplier, and Logistics Performance

---

## Executive Summary
This project designs an end-to-end supply chain analytics operating model that transforms fragmented operational data into decision-ready insights.

Rather than focusing on isolated dashboards or SQL queries, the solution demonstrates how analytics can be structured as a scalable enterprise capability supporting:
- Inventory optimization and working capital control
- Customer service performance (OTIF)
- Supplier reliability and upstream risk
- Transport cost vs service trade-offs
- Executive-level decision-making

---

## Strategic Objective
Design a decision-centric analytics platform that:
- Aligns data with business decisions
- Standardizes KPI definitions
- Enables cross-functional visibility
- Supports executive governance

---

## SQL Architecture
04_sql/
- 00_schema → Database & table setup
- 01_staging → Data cleaning
- 02_business_layer → Facts & dimensions
- 03_kpi_layer → KPI calculations
- 04_decision_marts → Decision datasets
- 05_quality_checks → Data validation

---

## Core Fact Tables
- fact_inventory_position → Inventory + risk
- fact_order_fulfillment → OTIF + service
- fact_procurement_reliability → Supplier performance
- fact_transport_execution → Logistics cost & service
- fact_demand_signal → Forecast vs actual

---

## Decision Marts
- mart_inventory_decision
- mart_replenishment_decision
- mart_supplier_risk
- mart_transport_tradeoff
- mart_executive_control_tower (main executive layer)

---

## Executive Alerts
- CRITICAL_SERVICE_AND_INVENTORY
- SUPPLIER_DRIVEN_SERVICE_RISK
- SERVICE_PROTECTED_BY_HIGH_FREIGHT_COST
- HIGH_INVENTORY_LOW_SERVICE_PARADOX
- STABLE_OR_REVIEW

---

## Why This Project Matters
This project demonstrates how to design analytics as a business operating model, not just technical reporting.

It reflects director-level thinking:
- decision ownership
- cross-functional analytics
- financial impact orientation

---

## Next Step
Build a Power BI Control Tower dashboard on top of mart_executive_control_tower.
