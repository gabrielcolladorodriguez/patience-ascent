#!/usr/bin/env python3
"""Interfaz gráfica para configurar Patience Ascent en App Store Connect."""

from __future__ import annotations

import io
import sys
import threading
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, scrolledtext, ttk

SCRIPT_DIR = Path(__file__).resolve().parent
ENV_PATH = SCRIPT_DIR / ".env"

HELP_TEXT = """CÓMO OBTENER LOS DATOS (5 minutos)

1. Entra en https://appstoreconnect.apple.com
2. Usuarios y acceso → Integraciones → App Store Connect API
3. Pulsa el botón "+" para crear una clave
4. Nombre: Patience Ascent
5. Rol: Admin (o App Manager)
6. Descargar → guarda el archivo AuthKey_XXXXX.p8

Copia estos valores en los campos de arriba:
• Issuer ID (arriba de la lista de claves)
• Key ID (columna de tu clave nueva)
• Archivo .p8 (botón Examinar)

IMPORTANTE: No pegues la clave en el chat de Cursor.
Solo se guarda en tu PC (scripts/.env).

Si algo falla, copia el texto del registro (abajo)
y pégalo en el chat — sin las claves."""


def load_env_values() -> dict[str, str]:
    values = {
        "issuer_id": "",
        "key_id": "",
        "key_path": "",
        "bundle_id": "com.patienceascent.app",
        "version": "1.0",
    }
    if not ENV_PATH.exists():
        return values
    for line in ENV_PATH.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, raw = line.split("=", 1)
        raw = raw.strip()
        if key == "ASC_ISSUER_ID":
            values["issuer_id"] = raw
        elif key == "ASC_KEY_ID":
            values["key_id"] = raw
        elif key == "ASC_PRIVATE_KEY_PATH":
            values["key_path"] = raw
        elif key == "ASC_BUNDLE_ID":
            values["bundle_id"] = raw
        elif key == "ASC_VERSION":
            values["version"] = raw
    return values


def save_env(values: dict[str, str]) -> None:
    content = f"""# Generado por configure_store_gui.py — no subir a GitHub
ASC_ISSUER_ID={values['issuer_id']}
ASC_KEY_ID={values['key_id']}
ASC_PRIVATE_KEY_PATH={values['key_path']}
ASC_BUNDLE_ID={values['bundle_id']}
ASC_VERSION={values['version']}
"""
    ENV_PATH.write_text(content, encoding="utf-8")


class StoreConfiguratorApp:
    def __init__(self) -> None:
        self.root = tk.Tk()
        self.root.title("Patience Ascent — Configurar App Store")
        self.root.geometry("760x720")
        self.root.minsize(640, 600)

        self._busy = False
        self._build_ui()
        self._load_saved()

    def _build_ui(self) -> None:
        pad = {"padx": 12, "pady": 4}
        frame = ttk.Frame(self.root, padding=12)
        frame.pack(fill=tk.BOTH, expand=True)

        ttk.Label(
            frame,
            text="Configura la tienda de Patience Ascent",
            font=("Segoe UI", 14, "bold"),
        ).pack(anchor=tk.W, pady=(0, 8))

        ttk.Label(
            frame,
            text="Rellena los 3 campos, pulsa Guardar y luego Configurar todo.",
            wraplength=700,
        ).pack(anchor=tk.W, pady=(0, 12))

        form = ttk.LabelFrame(frame, text="Clave API de App Store Connect", padding=10)
        form.pack(fill=tk.X, pady=(0, 10))

        self.issuer_var = tk.StringVar()
        self.key_id_var = tk.StringVar()
        self.key_path_var = tk.StringVar()
        self.bundle_var = tk.StringVar(value="com.patienceascent.app")
        self.version_var = tk.StringVar(value="1.0")

        self._row(form, "Issuer ID", self.issuer_var, 0)
        self._row(form, "Key ID", self.key_id_var, 1)

        path_row = ttk.Frame(form)
        path_row.grid(row=2, column=0, columnspan=2, sticky=tk.EW, pady=4)
        form.columnconfigure(1, weight=1)
        ttk.Label(path_row, text="Archivo .p8", width=14).pack(side=tk.LEFT)
        ttk.Entry(path_row, textvariable=self.key_path_var).pack(
            side=tk.LEFT, fill=tk.X, expand=True, padx=(0, 6)
        )
        ttk.Button(path_row, text="Examinar…", command=self._pick_p8).pack(side=tk.LEFT)

        extra = ttk.Frame(form)
        extra.grid(row=3, column=0, columnspan=2, sticky=tk.EW, pady=(8, 0))
        ttk.Label(extra, text="Bundle ID").pack(side=tk.LEFT)
        ttk.Entry(extra, textvariable=self.bundle_var, width=28).pack(
            side=tk.LEFT, padx=(6, 16)
        )
        ttk.Label(extra, text="Versión").pack(side=tk.LEFT)
        ttk.Entry(extra, textvariable=self.version_var, width=8).pack(side=tk.LEFT, padx=6)

        btns = ttk.Frame(frame)
        btns.pack(fill=tk.X, pady=8)

        ttk.Button(btns, text="❓ Ayuda", command=self._show_help).pack(side=tk.LEFT)
        ttk.Button(btns, text="Guardar", command=self._save).pack(side=tk.LEFT, padx=6)
        ttk.Button(btns, text="Probar conexión", command=self._test).pack(side=tk.LEFT, padx=6)
        self.btn_all = ttk.Button(
            btns, text="✓ Configurar tienda (38 idiomas)", command=self._configure_store
        )
        self.btn_all.pack(side=tk.LEFT, padx=6)
        self.btn_gc = ttk.Button(
            btns, text="✓ + Game Center (9 tablas)", command=self._configure_with_gc
        )
        self.btn_gc.pack(side=tk.LEFT, padx=6)

        log_frame = ttk.LabelFrame(frame, text="Registro", padding=6)
        log_frame.pack(fill=tk.BOTH, expand=True, pady=(8, 0))
        self.log = scrolledtext.ScrolledText(log_frame, height=18, font=("Consolas", 10))
        self.log.pack(fill=tk.BOTH, expand=True)
        self.log.configure(state=tk.DISABLED)

        ttk.Label(
            frame,
            text="Si hay error, copia el registro y pégalo en Cursor (sin las claves).",
            foreground="#555",
        ).pack(anchor=tk.W, pady=(8, 0))

    def _row(self, parent: ttk.LabelFrame, label: str, variable: tk.StringVar, row: int) -> None:
        ttk.Label(parent, text=label, width=14).grid(row=row, column=0, sticky=tk.W, pady=4)
        ttk.Entry(parent, textvariable=variable, width=60).grid(
            row=row, column=1, sticky=tk.EW, pady=4
        )

    def _load_saved(self) -> None:
        values = load_env_values()
        self.issuer_var.set(values["issuer_id"])
        self.key_id_var.set(values["key_id"])
        self.key_path_var.set(values["key_path"])
        self.bundle_var.set(values["bundle_id"])
        self.version_var.set(values["version"])
        if values["issuer_id"]:
            self._write("Datos cargados desde scripts/.env\n")

    def _pick_p8(self) -> None:
        path = filedialog.askopenfilename(
            title="Selecciona tu AuthKey_XXXXX.p8",
            filetypes=[("Clave API Apple", "*.p8"), ("Todos", "*.*")],
        )
        if path:
            self.key_path_var.set(path)

    def _show_help(self) -> None:
        messagebox.showinfo("Ayuda — Clave API", HELP_TEXT)

    def _validate(self) -> dict[str, str] | None:
        values = {
            "issuer_id": self.issuer_var.get().strip(),
            "key_id": self.key_id_var.get().strip(),
            "key_path": self.key_path_var.get().strip(),
            "bundle_id": self.bundle_var.get().strip() or "com.patienceascent.app",
            "version": self.version_var.get().strip() or "1.0",
        }
        if not values["issuer_id"]:
            messagebox.showerror("Falta dato", "Pon el Issuer ID.")
            return None
        if not values["key_id"]:
            messagebox.showerror("Falta dato", "Pon el Key ID.")
            return None
        if not values["key_path"]:
            messagebox.showerror("Falta dato", "Selecciona el archivo .p8 con Examinar.")
            return None
        if not Path(values["key_path"]).is_file():
            messagebox.showerror("Archivo no encontrado", f"No existe:\n{values['key_path']}")
            return None
        return values

    def _save(self) -> None:
        values = self._validate()
        if not values:
            return
        save_env(values)
        self._write("✓ Guardado en scripts/.env\n")

    def _set_busy(self, busy: bool) -> None:
        self._busy = busy
        state = tk.DISABLED if busy else tk.NORMAL
        self.btn_all.configure(state=state)
        self.btn_gc.configure(state=state)

    def _write(self, text: str) -> None:
        self.log.configure(state=tk.NORMAL)
        self.log.insert(tk.END, text)
        self.log.see(tk.END)
        self.log.configure(state=tk.DISABLED)

    def _run_task(self, title: str, func) -> None:
        if self._busy:
            return
        values = self._validate()
        if not values:
            return
        save_env(values)

        def worker() -> None:
            buffer = io.StringIO()
            old_stdout, old_stderr = sys.stdout, sys.stderr
            sys.stdout = sys.stderr = buffer
            try:
                func(values)
                buffer.write("\n✓ Terminado.\n")
            except Exception as exc:
                buffer.write(f"\nERROR: {exc}\n")
            finally:
                sys.stdout, sys.stderr = old_stdout, old_stderr
                output = buffer.getvalue()
                self.root.after(0, lambda: self._finish_task(output))

        self._set_busy(True)
        self._write(f"\n--- {title} ---\n")
        threading.Thread(target=worker, daemon=True).start()

    def _finish_task(self, output: str) -> None:
        self._write(output)
        self._set_busy(False)
        if "ERROR:" in output:
            messagebox.showerror("Algo falló", "Mira el registro abajo y copia el error para Cursor.")
        elif "✓ Terminado." in output:
            messagebox.showinfo("Listo", "Configuración aplicada. Revisa App Store Connect en el navegador.")

    def _make_client(self, values: dict[str, str]):
        from configure_app_store import ASCClient

        private_key = Path(values["key_path"]).read_text(encoding="utf-8")
        return ASCClient(values["issuer_id"], values["key_id"], private_key)

    def _test(self) -> None:
        def task(values: dict[str, str]) -> None:
            from configure_app_store import find_app

            client = self._make_client(values)
            app = find_app(client, values["bundle_id"])
            name = app["attributes"].get("name", "?")
            print(f"Conexión OK")
            print(f"App encontrada: {name}")
            print(f"ID: {app['id']}")

        self._run_task("Probar conexión", task)

    def _configure_store(self) -> None:
        def task(values: dict[str, str]) -> None:
            from configure_app_store import configure_store

            client = self._make_client(values)
            configure_store(
                client,
                bundle_id=values["bundle_id"],
                version=values["version"],
                game_center=False,
                screenshots_dir=None,
            )

        self._run_task("Configurar tienda", task)

    def _configure_with_gc(self) -> None:
        def task(values: dict[str, str]) -> None:
            from configure_app_store import configure_store

            client = self._make_client(values)
            configure_store(
                client,
                bundle_id=values["bundle_id"],
                version=values["version"],
                game_center=True,
                screenshots_dir=None,
            )

        self._run_task("Configurar tienda + Game Center", task)

    def run(self) -> None:
        self.root.mainloop()


def main() -> None:
    StoreConfiguratorApp().run()


if __name__ == "__main__":
    main()
