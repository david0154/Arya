from tkinter import *
from tkinter import filedialog, messagebox
from tkinter.ttk import Treeview
import sqlite3
import os
from datetime import date
from openpyxl import Workbook
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import A4

def show_main_ui():
    def connect_db():
        conn = sqlite3.connect("database.db")
        c = conn.cursor()
        c.execute('''CREATE TABLE IF NOT EXISTS entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            article TEXT, card TEXT, color TEXT, size TEXT, qty TEXT,
            component TEXT, print_opt TEXT, date TEXT
        )''')
        conn.commit()
        conn.close()

    def save_entry():
        data = (
            article_entry.get(), card_entry.get(), color_entry.get(),
            size_entry.get(), qty_entry.get(), component_entry.get(),
            print_var.get(), date_entry.get()
        )
        conn = sqlite3.connect("database.db")
        c = conn.cursor()
        c.execute("INSERT INTO entries (article, card, color, size, qty, component, print_opt, date) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", data)
        conn.commit()
        conn.close()
        messagebox.showinfo("Saved", "Entry saved successfully.")
        clear_form()
        update_dashboard()

    def update_dashboard():
        for row in tree.get_children():
            tree.delete(row)
        conn = sqlite3.connect("database.db")
        c = conn.cursor()
        query = "SELECT * FROM entries"
        filters = []
        if search_article.get():
            filters.append(f"article LIKE '%{search_article.get()}%'")
        if search_card.get():
            filters.append(f"card LIKE '%{search_card.get()}%'")
        if search_print.get() != "All":
            filters.append(f"print_opt = '{search_print.get()}'")
        if filters:
            query += " WHERE " + " AND ".join(filters)
        c.execute(query)
        rows = c.fetchall()
        for r in rows:
            tree.insert('', END, values=r)
        conn.close()

    def upload_image():
        filepath = filedialog.askopenfilename(filetypes=[("Image files", "*.jpg *.png")])
        if not filepath:
            return
        article = article_entry.get()
        if not article:
            messagebox.showerror("Error", "Enter article number first.")
            return
        os.makedirs("images", exist_ok=True)
        filename = f"images/{article}.jpg"
        with open(filepath, "rb") as src, open(filename, "wb") as dst:
            dst.write(src.read())
        messagebox.showinfo("Uploaded", "Image uploaded.")

    def export_excel():
        filepath = filedialog.asksaveasfilename(defaultextension=".xlsx", filetypes=[("Excel files", "*.xlsx")])
        if not filepath:
            return
        try:
            conn = sqlite3.connect("database.db")
            c = conn.cursor()
            c.execute("SELECT * FROM entries")
            rows = c.fetchall()
            conn.close()

            wb = Workbook()
            ws = wb.active
            ws.title = "Entries"
            ws.append(["ID", "Article", "Card", "Color", "Size", "Qty", "Component", "Print", "Date"])
            for row in rows:
                ws.append(row)
            wb.save(filepath)
            messagebox.showinfo("Exported", "Excel file saved successfully.")
        except Exception as e:
            messagebox.showerror("Export Failed", str(e))

    def export_pdf():
        filepath = filedialog.asksaveasfilename(defaultextension=".pdf", filetypes=[("PDF files", "*.pdf")])
        if not filepath:
            return
        try:
            conn = sqlite3.connect("database.db")
            c = conn.cursor()
            c.execute("SELECT * FROM entries")
            rows = c.fetchall()
            conn.close()

            c = canvas.Canvas(filepath, pagesize=A4)
            width, height = A4
            y = height - 40
            c.setFont("Helvetica-Bold", 14)
            c.drawString(50, y, "Entries Report")
            y -= 30
            c.setFont("Helvetica", 10)
            headers = ["ID", "Article", "Card", "Color", "Size", "Qty", "Component", "Print", "Date"]
            c.drawString(50, y, " | ".join(headers))
            y -= 20

            for row in rows:
                row_text = " | ".join(str(item) for item in row)
                c.drawString(50, y, row_text)
                y -= 15
                if y < 50:
                    c.showPage()
                    y = height - 40
            c.save()
            messagebox.showinfo("Exported", "PDF file saved.")
        except Exception as e:
            messagebox.showerror("PDF Error", str(e))

    def delete_entry():
        selected = tree.selection()
        if not selected:
            return messagebox.showwarning("Select", "Select entry to delete.")
        iid = tree.item(selected[0])['values'][0]
        conn = sqlite3.connect("database.db")
        c = conn.cursor()
        c.execute("DELETE FROM entries WHERE id=?", (iid,))
        conn.commit()
        conn.close()
        update_dashboard()

    def edit_entry():
        selected = tree.selection()
        if not selected:
            return messagebox.showwarning("Select", "Select entry to edit.")
        iid = tree.item(selected[0])['values'][0]
        conn = sqlite3.connect("database.db")
        c = conn.cursor()
        c.execute("SELECT * FROM entries WHERE id=?", (iid,))
        row = c.fetchone()
        conn.close()
        if row:
            article_entry.delete(0, END); article_entry.insert(0, row[1])
            card_entry.delete(0, END); card_entry.insert(0, row[2])
            color_entry.delete(0, END); color_entry.insert(0, row[3])
            size_entry.delete(0, END); size_entry.insert(0, row[4])
            qty_entry.delete(0, END); qty_entry.insert(0, row[5])
            component_entry.delete(0, END); component_entry.insert(0, row[6])
            print_var.set(row[7])
            date_entry.delete(0, END); date_entry.insert(0, row[8])
            tree.delete(selected[0])
            conn = sqlite3.connect("database.db")
            c = conn.cursor()
            c.execute("DELETE FROM entries WHERE id=?", (iid,))
            conn.commit()
            conn.close()

    def clear_form():
        for entry in [article_entry, card_entry, color_entry, size_entry, qty_entry, component_entry, date_entry]:
            entry.delete(0, END)
        print_var.set("Yes")

    root = Tk()
    root.title("Hype Production Management")
    root.geometry("1000x700")
    root.configure(bg="#e1f5fe")

    Label(root, text="Entry Form", font=("Arial", 16, "bold"), bg="#e1f5fe").pack(pady=5)

    form_frame = Frame(root, bg="#e1f5fe")
    form_frame.pack(pady=5)

    Label(form_frame, text="Article", bg="#e1f5fe").grid(row=0, column=0)
    article_entry = Entry(form_frame); article_entry.grid(row=0, column=1)

    Label(form_frame, text="Card", bg="#e1f5fe").grid(row=1, column=0)
    card_entry = Entry(form_frame); card_entry.grid(row=1, column=1)

    Label(form_frame, text="Color", bg="#e1f5fe").grid(row=2, column=0)
    color_entry = Entry(form_frame); color_entry.grid(row=2, column=1)

    Label(form_frame, text="Size", bg="#e1f5fe").grid(row=3, column=0)
    size_entry = Entry(form_frame); size_entry.grid(row=3, column=1)

    Label(form_frame, text="Qty", bg="#e1f5fe").grid(row=4, column=0)
    qty_entry = Entry(form_frame); qty_entry.grid(row=4, column=1)

    Label(form_frame, text="Component", bg="#e1f5fe").grid(row=5, column=0)
    component_entry = Entry(form_frame); component_entry.grid(row=5, column=1)

    Label(form_frame, text="Print?", bg="#e1f5fe").grid(row=6, column=0)
    print_var = StringVar(value="Yes")
    OptionMenu(form_frame, print_var, "Yes", "No").grid(row=6, column=1)

    Label(form_frame, text="Date (YYYY-MM-DD)", bg="#e1f5fe").grid(row=7, column=0)
    date_entry = Entry(form_frame)
    date_entry.grid(row=7, column=1)
    date_entry.insert(0, str(date.today()))

    Button(form_frame, text="Save Entry", command=save_entry, bg="#00796b", fg="white").grid(row=8, column=0, columnspan=2, pady=10)
    Button(form_frame, text="Upload Image", command=upload_image, bg="#039be5", fg="white").grid(row=9, column=0, columnspan=2)

    # Search and action buttons
    action_frame = Frame(root, bg="#e1f5fe")
    action_frame.pack(pady=10)

    search_article = Entry(action_frame, width=15)
    search_article.grid(row=0, column=0); search_article.insert(0, "")
    search_card = Entry(action_frame, width=15)
    search_card.grid(row=0, column=1); search_card.insert(0, "")
    search_print = StringVar(value="All")
    OptionMenu(action_frame, search_print, "All", "Yes", "No").grid(row=0, column=2)

    Button(action_frame, text="Search", command=update_dashboard, bg="#0288d1", fg="white").grid(row=0, column=3, padx=5)
    Button(action_frame, text="Export Excel", command=export_excel, bg="#388e3c", fg="white").grid(row=0, column=4, padx=5)
    Button(action_frame, text="Export PDF", command=export_pdf, bg="#5d4037", fg="white").grid(row=0, column=5, padx=5)
    Button(action_frame, text="Edit", command=edit_entry, bg="#fbc02d", fg="black").grid(row=0, column=6, padx=5)
    Button(action_frame, text="Delete", command=delete_entry, bg="#d32f2f", fg="white").grid(row=0, column=7, padx=5)

    # Treeview for entries
    tree = Treeview(root, columns=("ID", "Article", "Card", "Color", "Size", "Qty", "Component", "Print", "Date"), show="headings")
    for col in tree["columns"]:
        tree.heading(col, text=col)
    tree.pack(pady=10, fill="x", padx=10)

    connect_db()
    update_dashboard()
    root.mainloop()
