import tkinter as tk
from tkinter import messagebox, scrolledtext
import sqlite3

class CodeSnippetManager:
    def __init__(self, root):
        self.root = root
        self.root.title("Code Snippet Manager")
        self.root.geometry("600x400")

        # Create a database connection
        self.conn = sqlite3.connect("code_snippets.db")
        self.create_table()

        # Create a scrolled text widget
        self.text_area = scrolledtext.ScrolledText(self.root, wrap=tk.WORD, width=60, height=20)
        self.text_area.pack(pady=10)

        # Add buttons
        self.save_button = tk.Button(self.root, text="Save", command=self.save_snippet)
        self.save_button.pack(side=tk.LEFT, padx=10)
        
        self.clear_button = tk.Button(self.root, text="Clear", command=self.clear_text)
        self.clear_button.pack(side=tk.LEFT, padx=10)

        self.load_button = tk.Button(self.root, text="Load", command=self.load_snippet)
        self.load_button.pack(side=tk.LEFT, padx=10)

    def create_table(self):
        """Create table to store code snippets if not exists"""
        cursor = self.conn.cursor()
        cursor.execute('''CREATE TABLE IF NOT EXISTS snippets 
                          (id INTEGER PRIMARY KEY AUTOINCREMENT,
                           title TEXT,
                           description TEXT,
                           language TEXT,
                           tags TEXT,
                           code TEXT)''')
        self.conn.commit()

    def save_snippet(self):
        """Save code snippet to database"""
        snippet = self.text_area.get("1.0", tk.END)
        title = input("Enter snippet title: ")  # You can add a prompt for title
        description = input("Enter snippet description: ")  # You can add a prompt for description
        language = input("Enter snippet language: ")  # You can add a prompt for language
        tags = input("Enter snippet tags (comma-separated): ")  # You can add a prompt for tags
        try:
            cursor = self.conn.cursor()
            cursor.execute('''INSERT INTO snippets (title, description, language, tags, code)
                              VALUES (?, ?, ?, ?, ?)''', (title, description, language, tags, snippet))
            self.conn.commit()
            messagebox.showinfo("Success", "Snippet saved successfully!")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {e}")

    def load_snippet(self):
        """Load code snippet from database"""
        try:
            cursor = self.conn.cursor()
            cursor.execute("SELECT code FROM snippets")
            snippet = cursor.fetchone()[0]
            self.text_area.delete("1.0", tk.END)
            self.text_area.insert(tk.END, snippet)
            messagebox.showinfo("Success", "Snippet loaded successfully!")
        except TypeError:
            messagebox.showwarning("Warning", "No saved snippet found.")
        except Exception as e:
            messagebox.showerror("Error", f"An error occurred: {e}")

    def clear_text(self):
        """Clear text area"""
        self.text_area.delete("1.0", tk.END)

    def __del__(self):
        """Close database connection when the object is deleted"""
        self.conn.close()

if __name__ == "__main__":
    root = tk.Tk()
    app = CodeSnippetManager(root)
    root.mainloop()
