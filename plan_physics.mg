# M17-UC1 — Condiciones físicas y estrategia de modelado con FLASH

**Propósito.** Construir una hoja de ruta clara, en tres etapas, para simular la expansión/estructura de una región **H II ultracompacta** (M17-UC1) con FLASH 4.8, partiendo de un **modelo de juguete (A)** y escalando a un **modelo simplificado (B)** y un **modelo complejo (C)**.

---

## 1) Condiciones físicas y contexto observacional (resumen operativo)

- **Objeto:** región H II **ultracompacta** (tamaño ∼10³ AU), embebida en gas molecular denso y polvo, alrededor de una (proto)estrella masiva.
- **Medio circundante:** densidades altas (n_H ∼ 10^5–10^7 cm⁻³), temperaturas frías fuera de la H II (T ∼ 10–50 K), posibles gradientes y **no uniformidad**.
- **Cavidad ionizada:** gas ionizado caliente (T_e ∼ 7,000–10,000 K), **sobrepresión** que impulsa una expansión transónica/supersónica en el gas neutro.
- **Fuente central:** estrella joven OB (Q_H ≳ 10^47–10^49 s⁻¹), aporta **ionización** y **calentamiento** (y, si se desea, gravedad). La radiación crea un **frente de ionización** y un **frente de choque** en el neutro.
- **Cinemática esperada:** cascarón en expansión (decenas de km/s a escalas ≲10³ AU, sensible al gradiente de densidad y a la geometría).

> **Notas prácticas para el modelado:**  
> (i) Si no hay RT fotoionizante explícito, se puede **aproximar** el efecto con un **depósito energético** (inicial o continuo) y/o un **campo de calentamiento**.  
> (ii) La **gravedad** del objeto central modula la morfología interna y puede añadirse en etapas posteriores.  
> (iii) La **química** (H↔H⁺) y el **enfriamiento radiativo** ajustan la anchura del frente y la termodinámica, pero pueden aproximarse en A) con EOS γ y un *source term* térmico efectivo.

---

## 2) Procesos físicos clave a simular (y justificación)

1. **Hidrodinámica compresible (Hydro + EOS Γ):** captura choques, cascarones y flujo global. *Imprescindible* desde A.
2. **Radiación/ionización (proxy de calentamiento):** la energía foto-depositada sostiene la sobrepresión. En A se modela como **sobrepresión inicial**; en B como **calentamiento volumétrico** (o RadTrans difusivo); en C como **RT fotoionizante**/química.
3. **Gravedad del objeto central:** afecta la estructura interna y la cinemática cerca de la fuente. Añadir en B/C si se quiere colapso o contención parcial.
4. **Enfriamiento / conducción / química H:** controlan T_e y el grosor del frente; se introducen gradualmente (B y más en C).
5. **Geometría & no-uniformidad del medio:** UC1 vive en medios **clumpeados**; se introduce subestructura de densidad en B/C.
6. **(Opcional) MHD:** el campo B puede frenar y colimar; dejar para C si se dispone de MHD en FLASH y recursos de cómputo.

---

## 3) Parámetros fundamentales del modelo

- **Dominio y resolución:** lado L_box y Δx. Para UC1, L_box ≳ (5–10)×R_HII; resolución objetivo Δx ≲ 30 AU (toy: 30–60 AU).  
- **Medio neutro:** densidad `n_H` (→ ρ = μ m_H n_H, con μ ≃ 1.3), temperatura `T_n`. Ejemplo: n_H = 10^6 cm⁻³ ⇒ ρ ≃ 2.2×10⁻¹⁸ g cm⁻³.
- **Cavidad/depósito energético:** radio inicial R₀ y energía E₀ (o tasa \\.E_heat). Sintoniza el **radio y velocidad** de expansión.
- **EOS:** γ ≈ 5/3 (gas monoatómico). En C, γ efectivo o 3-T.
- **Gravedad:** masa central M_* (y, si se usa, radio de suavizado).
- **Refinamiento AMR:** `lrefine_min/max`, variable de refinamiento (dens/∇p/∇ρ), umbrales.
- **Fronteras:** típicamente **outflow** en x/y/z.
- **Salida:** frecuencia de *plotfiles* y *checkpoints* en tiempo físico.

---

## 4) Estrategia de modelado en **tres etapas**

### A) **Modelo de Juguete** (mínimo viable, 3D Hydro + EOS Γ)
**Objetivo:** reproducir la expansión de una burbuja caliente en un medio denso, para calibrar radios/velocidades y la malla AMR sin complicaciones adicionales.

- **Física:** Hydro + EOS Γ. Sin gravedad, sin química explícita.  
- **Inicialización:** esfera central de radio `R0` **caliente y/o sobrepresionada**; resto del dominio homogéneo frío y denso.  
- **AMR:** refinar en gradientes de densidad/presión para capturar el cascarón.  
- **Métricas:** R_HII(t), v_exp, perfiles ρ(r), p(r), T(r).

**Parámetros guía (ejemplo):**
- `L_box = 0.05 pc` (~10,300 AU); `Δx_target ≃ 32 AU`  
- Medio: `n_H = 1e6 cm⁻³`, `T_n = 30 K` → ρ ≃ 2.2×10⁻¹⁸ g cm⁻³  
- Cavidad: `R0 = 150 AU`, `T0 = 10,000 K` (equivalente a presión elevada)

---

### B) **Modelo Simplificado más realista**
**Objetivo:** acercar la termodinámica y morfología a UC1 introduciendo **calentamiento continuo** (proxy de fotoionización), **enfriamiento**, **gravedad** y **no-uniformidad**.

- **Añadir:**  
  - **Fuente térmica** central \\( \\.E_{heat}(r) \\) estacionaria (o RadTrans difusivo “gris” si se desea).  
  - **Enfriamiento** (tabla o ley paramétrica) para gas ionizado y neutro.  
  - **Gravedad** puntual (M_* fija) con suavizado pequeño.  
  - **Clumps**: fluctuaciones de densidad (p.ej., campo log-normal) para ver asimetrías.

- **Métricas nuevas:** anchura del frente, asimetría del cascarón, tasa de fuga, dependencia con M_* y \\( \\.E_{heat} \\).

---

### C) **Modelo Complejo y realista**
**Objetivo:** incluir **RT fotoionizante**/química H↔H⁺, **polvo** y (opcional) **MHD**.

- **Añadir:**  
  - **RT** (método disponible en tu instalación; p.ej. difusivo gris + fuente espectral ajustada, o acople a módulo fotoionizante si se habilita).  
  - **Química** de H (ionización/recombinación) y **enfriamiento** dependiente de ionización.  
  - **(Opc.) MHD** para evaluar confinamiento y anisotropías.  
- **Métricas:** EM, RRL/anchos (si se post-procesa), mapas sintéticos.

> **Nota de recursos:** B y C exigen más CPU/memoria; sube `lrefine_max` de forma escalonada y usa tests pequeños antes de campañas largas.

---

## 5) Archivo de configuración (FLASH **`flash.par`**) — **Modelo A**

> **Importante:** este `flash.par` **no** introduce parámetros personalizados (`sim_*`). Usa sólo *runtime params* estándar de FLASH (Grid/Hydro/IO), por lo que puedes correrlo como **plantilla de juguete** **si** tu `Simulation_init` crea la cavidad inicial (o si copias el `Simulation_init` de `Sedov` como base).

```ini
# === Control de ejecución ===
eos_gamma                 = 1.6666667
cfl                          = 0.8
useHydro                     = .true.
useGravity                   = .false.

# === Dominio (3D, unidades CGS) ===
xmin = -7.5e16   ; xmax =  7.5e16    # ~0.0486 pc de lado total
ymin = -7.5e16   ; ymax =  7.5e16
zmin = -7.5e16   ; zmax =  7.5e16

# Fronteras
xl_boundary_type = "outflow"
xr_boundary_type = "outflow"
yl_boundary_type = "outflow"
yr_boundary_type = "outflow"
zl_boundary_type = "outflow"
zr_boundary_type = "outflow"

# === AMR (Paramesh) ===
lrefine_min = 2
lrefine_max = 7                  # Δx_min ~ L_box / (8 * 2^(lrefine_max-1)) ≈ 30–40 AU
refine_var_1 = "dens"
refine_var_2 = "pres"
refine_cutoff_1  = 0.8
derefine_cutoff_1 = 0.2
refine_cutoff_2  = 0.8
derefine_cutoff_2 = 0.2

# === Salida ===
plot_var_1 = "dens"
plot_var_2 = "temp"
plot_var_3 = "pres"
plot_var_4 = "velx"
plot_var_5 = "vely"
plot_var_6 = "velz"

plot_interval     = 10     # cada 10 pasos de tiempo
checkpointFileInterval = 200

# === Parada ===
tmax    = 3.0e9           # ~95 años
nend    = 100000
