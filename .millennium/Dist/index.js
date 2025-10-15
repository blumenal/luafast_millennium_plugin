const MILLENNIUM_IS_CLIENT_MODULE = !0, pluginName = "luafast";
function InitializePlugins() {
    var e, t;
    let a;
    (e = window.PLUGIN_LIST || (window.PLUGIN_LIST = {})).luafast || (e.luafast = {}),
    (t = window.MILLENNIUM_PLUGIN_SETTINGS_STORE || (window.MILLENNIUM_PLUGIN_SETTINGS_STORE = {})).luafast || (t.luafast = {}),
    window.MILLENNIUM_SIDEBAR_NAVIGATION_PANELS || (window.MILLENNIUM_SIDEBAR_NAVIGATION_PANELS = {}),
    function (e) {
        e[e.CallServerMethod = 0] = "CallServerMethod"
    }(a || (a = {}));
    let n = window.MILLENNIUM_PLUGIN_SETTINGS_STORE.luafast, i = "Millennium.Internal.IPC.[luafast]";
    const o = {
        DropDown: ["string", "number", "boolean"],
        NumberTextInput: ["number"],
        StringTextInput: ["string"],
        FloatTextInput: ["number"],
        CheckBox: ["boolean"],
        NumberSlider: ["number"],
        FloatSlider: ["number"]
    };
    function r(e, t, n) {
        return MILLENNIUM_BACKEND_IPC.postMessage(a.CallServerMethod, {
            pluginName: e,
            methodName: "__builtins__.__update_settings_value__",
            argumentList: { name: t, value: n }
        })
    }
    n.ignoreProxyFlag = !1,
    async function () {
        for (; "undefined" == typeof MainWindowBrowserManager;)
            await new Promise(e => setTimeout(e, 0));
        MainWindowBrowserManager?.m_browser?.on("message", (e, t) => {
            if (e !== i)
                return;
            const { name: a, value: o } = JSON.parse(t);
            n.ignoreProxyFlag = !0,
            n.settingsStore[a] = o,
            r("luafast", a, o),
            n.ignoreProxyFlag = !1
        })
    }();
    const s = e => new Proxy(e, {
        set(e, t, a) {
            if (!(t in e))
                throw new TypeError(`Property ${String(t)} does not exist on plugin settings`);
            const s = o[e[t].type], l = e[t]?.range;
            if (s.includes("number") && "number" == typeof a && (l && (a = function (e, t, a) {
                return Math.max(t, Math.min(a, e))
            }(a, l[0], l[1])), a || (a = 0)),
            !s.includes(typeof a))
                throw new TypeError(`Expected ${s.join(" or ")}, got ${typeof a}`);
            return e[t].value = a,
            ((e, t) => {
                n.ignoreProxyFlag || (r("luafast", e, t),
                "undefined" != typeof MainWindowBrowserManager && MainWindowBrowserManager?.m_browser?.PostMessage(i, JSON.stringify({
                    name: e,
                    value: t
                })))
            }
            )(String(t), a),
            !0
        },
        get: (e, t) => "__raw_get_internals__" === t ? e : t in e ? e[t].value : void 0
    });
    n.DefinePluginSetting = s,
    n.settingsStore = s({})
}
InitializePlugins();
const __call_server_method__ = (e, t) => Millennium.callServerMethod("luafast", e, t), __wrapped_callable__ = e => MILLENNIUM_API.callable(__call_server_method__, e);
let PluginEntryPointMain = function () {
    return function (e) {
        "use strict";
        const t = "en", a = {
            en: {
                btn: {
                    add: "Add via luafast",
                    remove: "Remove via luafast",
                    loading: "Loading...",
                    removing: "Removing...",
                    cancel: "Cancel"
                },
                status: {
                    downloading: "Downloading and installing game files...",
                    checking: "Checking availability…",
                    checkingApi: "Checking {api}…",
                    queued: "Initializing download…",
                    downloadingProgress: "Downloading from {endpoint}… ({downloaded}MB / {total}MB)",
                    processing: "Processing ZIP package…",
                    extracting: "Extracting game files…",
                    extractingCount: "Extracting game files… ({count} files processed)",
                    installing: "Installing to Steam…",
                    failed: "Download failed",
                    gameAdded: "Game Added Successfully!",
                    authFailed: "API key authentication failed"
                },
                generic: {
                    error: "Error",
                    close: "Close"
                }
            },
            es: {
                btn: {
                    add: "Añadir vía luafast",
                    remove: "Eliminar vía luafast",
                    loading: "Cargando...",
                    removing: "Eliminando...",
                    cancel: "Cancelar"
                },
                status: {
                    downloading: "Descargando e instalando archivos del juego...",
                    checking: "Verificando disponibilidad…",
                    checkingApi: "Verificando {api}…",
                    queued: "Inicializando descarga…",
                    downloadingProgress: "Descargando desde {endpoint}… ({downloaded}MB / {total}MB)",
                    processing: "Procesando paquete ZIP…",
                    extracting: "Extrayendo archivos del juego…",
                    extractingCount: "Extrayendo archivos del juego… ({count} archivos procesados)",
                    installing: "Instalando en Steam…",
                    failed: "Descarga fallida",
                    gameAdded: "¡Juego añadido con éxito!",
                    authFailed: "Error de autenticación de clave API"
                },
                generic: {
                    error: "Error",
                    close: "Cerrar"
                }
            },
            "pt-BR": {
                btn: {
                    add: "Grátis - LuaFast",
                    remove: "Remover da Biblioteca",
                    loading: "Carregando...",
                    removing: "Removendo...",
                    cancel: "Cancelar"
                },
                status: {
                    downloading: "Baixando e instalando arquivos do jogo...",
                    checking: "Verificando disponibilidade…",
                    checkingApi: "Verificando {api}…",
                    queued: "Inicializando download…",
                    downloadingProgress: "Baixando de {endpoint}… ({downloaded}MB / {total}MB)",
                    processing: "Processando pacote ZIP…",
                    extracting: "Extraindo arquivos do jogo…",
                    extractingCount: "Extraindo arquivos do jogo… ({count} arquivos processados)",
                    installing: "Instalando na Steam…",
                    failed: "Download falhou",
                    gameAdded: "Jogo adicionado com sucesso!",
                    authFailed: "Falha na autenticação da chave API"
                },
                generic: {
                    error: "Erro",
                    close: "Fechar"
                }
            },
            fr: {
                btn: {
                    add: "Ajouter avec luafast",
                    remove: "Retirer avec luafast",
                    loading: "Chargement ...",
                    removing: "Suppression...",
                    cancel: "Annuler"
                },
                status: {
                    downloading: "Téléchargement et installation des fichiers du jeu...",
                    checking: "Verification de la disponibilité…",
                    checkingApi: "Verification de {api}…",
                    queued: "Début du téléchargement…",
                    downloadingProgress: "Téléchargement depuis {endpoint}… ({downloaded}MB / {total}MB)",
                    processing: "Prise en charge de l'archive ZIP…",
                    extracting: "Extraction des fichiers du jeu…",
                    extractingCount: "Extraction des fichiers du jeu… ({count} fichiers extraits)",
                    installing: "Installation sur Steam…",
                    failed: "Téléchargement échoué",
                    gameAdded: "Jeu correctement ajouté!",
                    authFailed: "Échec de l'authentification de la clé API"
                },
                generic: {
                    error: "Erreur",
                    close: "Fermer"
                }
            },
            it: {
                btn: {
                    add: "Aggiungi con luafast",
                    remove: "Rimuovi con luafast",
                    loading: "Caricamento...",
                    removing: "Rimozione in corso...",
                    cancel: "Annulla"
                },
                status: {
                    downloading: "Scaricamento e installazione del gioco in corso...",
                    checking: "Verifica disponibilità…",
                    checkingApi: "Verifica {api}…",
                    queued: "Inizializzazione download…",
                    downloadingProgress: "Scaricamento da {endpoint}… ({downloaded}MB / {total}MB)",
                    processing: "Elaborazione pacchetto ZIP…",
                    extracting: "Estrazione dei file di gioco…",
                    extractingCount: "Estrazione dei file di gioco… ({count} file elaborati)",
                    installing: "Installazione su Steam…",
                    failed: "Scaricamento non riuscito",
                    gameAdded: "Gioco aggiunto con successo!",
                    authFailed: "Autenticazione chiave API fallita"
                },
                generic: {
                    error: "Errore",
                    close: "Chiudi"
                }
            }
        }, n = new class {
            constructor() {
                this.translations = new Map,
                this.currentLocale = t,
                this.initialised = !1,
                this.initPromise = null
            }
            async init() {
                this.initialised || (this.initPromise || (this.initPromise = this.bootstrap()),
                await this.initPromise,
                this.initialised = !0)
            }
            t(e, a) {
                const n = this.lookup(this.currentLocale, e) ?? this.lookup(t, e) ?? e;
                return "string" != typeof n ? e : a ? n.replace(/\{(.*?)\}/g, (e, t) => {
                    const n = a[t.trim()];
                    return null == n ? "" : String(n)
                }) : n
            }
            async bootstrap() {
                const e = function (e) {
                    if ("string" != typeof e)
                        return t;
                    const n = e.toLowerCase();
                    if ("pt-br" === n || "pt_br" === n)
                        return "pt-BR";
                    if (n.startsWith("en"))
                        return "en";
                    if (n.startsWith("es"))
                        return "es";
                    const i = n.split(/[-_]/)[0];
                    return Object.keys(a).find(e => e.toLowerCase() === i) ?? t
                }(navigator.language || navigator.userLanguage || t);
                if (this.loadLocale(e), !this.translations.has(e) && e !== t)
                    return this.loadLocale(t),
                    void (this.currentLocale = t);
                this.currentLocale = e
            }
            loadLocale(e) {
                if (this.translations.has(e))
                    return;
                const t = a[e];
                t && this.translations.set(e, t)
            }
            lookup(e, t) {
                const a = this.translations.get(e);
                if (a)
                    return t.split(".").reduce((e, t) => {
                        if (e && "object" == typeof e)
                            return e[t]
                    }, a)
            }
        };
        function i(e, t) {
            return n.t(e, t)
        }
        let r = !1;
        function s(e) {
            try {
                "function" == typeof Millennium?.callServerMethod && __call_server_method__("Logger.log", {
                    message: String(e)
                }).catch(() => {})
            } catch (e) {
                console.warn("[luafast] backendLog failed", e)
            }
        }
        async function l(e, t) {
            try {
                const a = void 0 === t ? await __call_server_method__(e) : await __call_server_method__(e, t);
                if ("string" == typeof a)
                    try {
                        return JSON.parse(a)
                    } catch {
                        return a
                    }
                return a
            } catch (t) {
                throw s(`Backend call failed: ${e} - ${String(t)}`),
                t
            }
        }
        async function d(e, t, a, n, r, d) {
            s(`Starting add flow for app ${e}`);
            a.textContent = i("btn.loading"),
            t.style.opacity = "0.7";
            const m = function (e = "status.downloading") {
                let t = i(e), a = null, n = null, o = null, r = !1;
                const s = () => {
                    if (!r) {
                        if (a || (a = document.querySelector('.newmodal[data-luafast-modal="download"]')),
                        !a) {
                            const e = document.querySelector(".newmodal");
                            e && (e.setAttribute("data-luafast-modal", "download"),
                            a = e)
                        }
                        a && (n || (n = a.querySelector(".newmodal_content"),
                        n || (n = document.createElement("div"),
                        a.appendChild(n))),
                        n && (o ? o.textContent = t : (n.innerHTML = "",
                        o = document.createElement("div"),
                        o.style.minHeight = "40px",
                        o.style.display = "flex",
                        o.style.alignItems = "center",
                        o.style.color = "#ffffff",
                        o.textContent = t,
                        n.appendChild(o))))
                    }
                }, l = () => {
                    s(),
                    o || setTimeout(s, 120)
                }, c = (e = 0) => {
                    r || (r = !0,
                    setTimeout(() => {
                        try {
                            const e = window.CModal;
                            a && a.matches('.newmodal[data-luafast-modal="download"]') && e?.DismissActiveModal ? e.DismissActiveModal() : a && "function" == typeof a.remove && a.remove()
                        } catch {
                            a && "function" == typeof a.remove && a.remove()
                        }
                    }, Math.max(0, e)))
                };
                if ("function" == typeof ShowAlertDialog)
                    try {
                        ShowAlertDialog(i("generic.download"), t)
                    } catch (e) {
                        console.warn("luafast: failed to open download modal via ShowAlertDialog", e)
                    }
                else {
                    const e = document.createElement("div");
                    e.setAttribute("data-luafast-modal", "download"),
                    e.style.position = "fixed",
                    e.style.top = "0",
                    e.style.left = "0",
                    e.style.right = "0",
                    e.style.bottom = "0",
                    e.style.display = "flex",
                    e.style.alignItems = "center",
                    e.style.justifyContent = "center",
                    e.style.background = "rgba(0,0,0,0.6)",
                    e.style.zIndex = "10000";
                    const r = document.createElement("div");
                    r.style.background = "#1b2838",
                    r.style.border = "1px solid #67c1f5",
                    r.style.borderRadius = "4px",
                    r.style.padding = "18px",
                    r.style.minWidth = "280px",
                    r.style.color = "#ffffff",
                    r.style.fontFamily = "sans-serif",
                    o = document.createElement("div"),
                    o.textContent = t,
                    o.style.marginBottom = "12px";
                    const s = document.createElement("button");
                    s.type = "button",
                    s.textContent = i("generic.close"),
                    s.style.marginTop = "12px",
                    s.onclick = () => c(0),
                    r.appendChild(o),
                    r.appendChild(s),
                    e.appendChild(r),
                    document.body.appendChild(e),
                    a = e,
                    n = r
                }
                return l(),
                {
                    update: e => {
                        t = e,
                        r || (o || l(),
                        o && (o.textContent = e))
                    },
                    close: c
                }
            }();
            try {
                const t = await l("addVialuafast", {
                    appid: e
                });
                if (t?.success)
                    return function (e, t, a) {
                        let n = !1;
                        const r = e => {
                            if (!n) {
                                n = !0,
                                window.clearInterval(d);
                                try {
                                    e()
                                } finally {
                                    a.markIdle()
                                }
                            }
                        }, d = window.setInterval(async () => {
                            if (n)
                                window.clearInterval(d);
                            else
                                try {
                                    const n = await l("GetStatus", {
                                        appid: e
                                    });
                                    if (!1 === n?.success) {
                                        const e = n?.error ?? i("generic.error");
                                        return t.update(`${i("status.failed")}: ${e}`),
                                        t.close(2500),
                                        void r(() => a.onFailed(e))
                                    }
                                    const s = n?.state ?? n;
                                    if (!s || "object" != typeof s)
                                        return;
                                    const d = "string" == typeof s.status ? s.status.toLowerCase() : "";
                                    if (t.update((e => {
                                        switch ("string" == typeof e.status ? e.status.toLowerCase() : "") {
                                        case "checking":
                                            return e.currentApi ? i("status.checkingApi", {
                                                api: e.currentApi
                                            }) : i("status.checking");
                                        case "checking_availability":
                                            return i("status.checking");
                                        case "queued":
                                            return i("status.queued");
                                        case "downloading":
                                            if ("number" == typeof e.bytesRead && "number" == typeof e.totalBytes && e.totalBytes > 0) {
                                                const t = (e.bytesRead / 1048576).toFixed(1), a = (e.totalBytes / 1048576).toFixed(1), n = Math.min(100, Math.max(0, Math.floor(e.bytesRead / e.totalBytes * 100)));
                                                return `${i("status.downloadingProgress",{
                                                    downloaded: t,
                                                    total: a
                                                })} (${n}%)`
                                            }
                                            return i("status.downloading");
                                        case "processing":
                                            return i("status.processing");
                                        case "extracting":
                                            return "number" == typeof e.extractedFiles ? i("status.extractingCount", {
                                                count: e.extractedFiles
                                            }) : i("status.extracting");
                                        case "installing":
                                            if (Array.isArray(e.installedFiles) && e.installedFiles.length > 0)
                                                return `${i("status.installing")} ${e.installedFiles[e.installedFiles.length-1]}`;
                                            if ("string" == typeof e.installedPath) {
                                                const t = e.installedPath.split(/[\\/]/);
                                                return `${i("status.installing")} ${t[t.length-1]}`
                                            }
                                            return i("status.installing");
										case "done":
											t.close(0);
											setTimeout(() => {
												if (typeof ShowAlertDialog === 'function') {
													ShowAlertDialog(
														i("status.gameAdded"),
														"Processo concluído com sucesso! Para aplicar as mudanças, pressione o botão 'Restart Steam' no canto inferior esquerdo.\nParticipe do nosso grupo e fique por dentro das novidades. https://t.me/luafaststeamgames"
													);
												} else {
													alert(i("status.gameAdded") + "\n\nProcesso concluído com sucesso! Para aplicar as mudanças, pressione o botão 'Restart Steam' no canto inferior esquerdo.");
												}
											}, 100);
											return i("status.gameAdded");
                                        case "failed":
                                            return e.error ? `${i("status.failed")}: ${e.error}` : i("status.failed");
                                        default:
                                            return "string" == typeof e.status && "" !== e.status.trim() ? e.status : "string" == typeof e.message ? e.message : i("status.downloading")
                                        }
                                    })(s)),
                                    "done" === d)
                                        t.update(i("status.gameAdded")),
                                        t.close(2e3),
                                        r(a.onDone);
                                    else if ("failed" === d) {
                                        const e = s.error ?? i("generic.error");
                                        t.update(`${i("status.failed")}: ${e}`),
                                        t.close(2500),
                                        r(() => a.onFailed(e))
                                    }
                                } catch (e) {
                                    s(`Progress monitoring error: ${String(e)}`)
                                }
                        }, 600)
                    }(e, m, {
                        onDone: () => {
                            n.remove(),
                            setTimeout(() => {
                                u().catch(e => s(`Re-injection error: ${String(e)}`))
                            }, 250)
                        },
                        onFailed: () => {
                            r()
                        },
                        markIdle: d
                    }),
                    !0;
                const a = t?.error ?? i("generic.error");
                return s(`Download failed: ${a}`),
                m.update(`${i("status.failed")}: ${a}`),
                m.close(2500),
                d(),
                !1
            } catch (e) {
                const t = String(e);
                return s(`Download start error: ${t}`),
                m.update(`${i("status.failed")}: ${t}`),
                m.close(2500),
                d(),
                !1
            }
        }
        
        // Variável para controlar o estado atual do app
        let currentAppId = null;
        let currentButtonState = null;
        
        async function u() {
            const e = function () {
                const e = window.location.href.match(/\/app\/(\d+)/);
                if (e)
                    return parseInt(e[1], 10);
                const t = document.querySelector("[data-appid]");
                if (t) {
                    const e = t.getAttribute("data-appid");
                    if (e) {
                        const t = parseInt(e, 10);
                        if (!Number.isNaN(t))
                            return t
                    }
                }
                return null
            }();
            
            // Se não há appid, limpar estado e retornar
            if (!e) {
                currentAppId = null;
                currentButtonState = null;
                return;
            }
            
            // Se o appid mudou, limpar botões existentes
            if (currentAppId !== e) {
                document.querySelectorAll('[data-luafast-button]').forEach(btn => {
                    btn.remove();
                });
                currentAppId = e;
                currentButtonState = null;
            }
            
            const t = function () {
                const e = [".game_area_purchase_game_wrapper .game_purchase_action_bg", ".game_area_purchase_game:not(.demo_above_purchase) .game_purchase_action_bg", ".game_area_purchase_game:not(.demo_above_purchase) .game_purchase_action", ".game_area_purchase_game:not(.demo_above_purchase) .btn_addtocart", ".game_area_purchase_game_wrapper", ".game_purchase_action_bg", ".game_purchase_action", ".btn_addtocart", '[class*="purchase"]'];
                for (const t of e) {
                    const e = document.querySelector(t);
                    if (e)
                        return t.endsWith(".btn_addtocart") ? e.parentElement : e
                }
                return null
            }();
            
            if (t) {
                // VERIFICAR SE JÁ EXISTE UM BOTÃO LUFAST NESTE CONTAINER
                if (t.querySelector('[data-luafast-button]')) {
                    return;
                }
                
                try {
                    const a = await l("hasluaForApp", {
                        appid: e
                    }), n = Boolean(a?.exists);
                    
                    // Se o estado não mudou, não reinjetar
                    if (currentButtonState === n) {
                        return;
                    }
                    currentButtonState = n;
                    
                    const o = document.createElement("div");
                    o.className = "btn_addtocart btn_packageinfo";
                    o.setAttribute("data-luafast-button", "true");
                    
                    const c = document.createElement("span");
                    c.setAttribute("role", "button");
                    c.className = "btn_blue_steamui btn_medium";
                    c.style.marginLeft = "2px";
                    
                    const m = document.createElement("span");
                    m.textContent = i(n ? "btn.remove" : "btn.add");
                    c.appendChild(m);
                    o.appendChild(c);
                    
                    c.onclick = async t => {
                        if (t.preventDefault(),
                        t.stopPropagation(),
                        r)
                            return;
                        r = !0;
                        
                        const a = () => {
                            c.style.pointerEvents = "auto";
                            c.style.opacity = "1";
                            m.textContent = i(n ? "btn.remove" : "btn.add");
                            r = false;
                        };
                        
                        if (n) {
                            c.style.pointerEvents = "none";
                            c.style.opacity = "0.7";
                            m.textContent = i("btn.removing");
                            
                            const t = await async function (e, t, a) {
                                s(`Starting remove flow for app ${e}`);
                                try {
                                    const n = await l("removeVialuafast", {
                                        appid: e
                                    });
                                    if (n?.success) {
                                        s("Game removed successfully from luafast");
                                        return true;
                                    } else {
                                        s(`Failed to remove game: ${n?.error??i("generic.error")}`);
                                        return false;
                                    }
                                } catch (e) {
                                    s(`Remove error: ${String(e)}`);
                                    return false;
                                }
                            }(e, c, m);
                            
                            r = !1;
                            
                            if (t) {
                                // Forçar atualização do estado
                                currentButtonState = null;
                                o.remove();
                                
                                setTimeout(() => {
                                    u().catch(e => s(`Re-injection error: ${String(e)}`));
                                }, 100);
                            } else {
                                a();
                            }
                            return;
                        }
                        
                        c.style.pointerEvents = "none";
                        c.style.opacity = "0.7";
                        m.textContent = i("btn.loading");
                        
                        await d(e, c, m, o, a, () => {
                            r = !1
                        }) ? m.textContent = i("status.downloading") : a();
                    };
                    
                    t.appendChild(o);
                } catch (e) {
                    s(`Failed to inject button: ${String(e)}`);
                }
            }
        }
        
        let m = null;
        let injectionTimeout = null;
        let lastUrl = '';

        return e.default = async function () {
            await async function () {
                await n.init()
            }();
            
            setTimeout(() => {
                new MutationObserver(() => {
                    const currentUrl = window.location.href;
                    
                    // Só processar se a URL mudou ou se estamos em uma página de app
                    if (currentUrl.includes("/app/")) {
                        if (currentUrl !== lastUrl) {
                            lastUrl = currentUrl;
                            // Resetar estado quando a URL muda
                            currentAppId = null;
                            currentButtonState = null;
                        }
                        
                        m && clearTimeout(m);
                        m = setTimeout(() => {
                            if (injectionTimeout) clearTimeout(injectionTimeout);
                            injectionTimeout = setTimeout(() => {
                                u().catch(e => s(`Inject error: ${String(e)}`));
                            }, 500); // Aumentar o debounce
                        }, 300);
                    }
                }).observe(document.body, {
                    childList: true,
                    subtree: true
                });
                
                u().catch(e => s(`Initial inject error: ${String(e)}`));
            }, 1000);
        },
        Object.defineProperty(e, "__esModule", {
            value: !0
        }),
        e
    }({})
};
function ExecutePluginModule() {
    let e = window.MILLENNIUM_PLUGIN_SETTINGS_STORE.luafast;
    e.OnPluginConfigChange = function (t, a, n) {
        t in e.settingsStore && (e.ignoreProxyFlag = !0,
        e.settingsStore[t] = n,
        e.ignoreProxyFlag = !1)
    },
    MILLENNIUM_BACKEND_IPC.postMessage(0, {
        pluginName: "luafast",
        methodName: "__builtins__.__millennium_plugin_settings_parser__"
    }).then(async t => {
        "string" == typeof t.returnValue && (e.ignoreProxyFlag = !0,
        e.settingsStore = e.DefinePluginSetting(Object.fromEntries(JSON.parse(atob(t.returnValue)).map(e => [e.functionName, e]))),
        e.ignoreProxyFlag = !1);
        let a = PluginEntryPointMain();
        Object.assign(window.PLUGIN_LIST.luafast, { ...a,
            __millennium_internal_plugin_name_do_not_use_or_change__: "luafast"
        });
        let n = await a.default();
        var i;
        n && (i = n) && void 0 !== i.title && void 0 !== i.icon && void 0 !== i.content ? (window.MILLENNIUM_SIDEBAR_NAVIGATION_PANELS.luafast = n,
        MILLENNIUM_BACKEND_IPC.postMessage(1, {
            pluginName: "luafast"
        })) : console.warn("Plugin luafast does not contain proper SidebarNavigation props and therefor can't be mounted by Millennium. Please ensure it has a title, icon, and content.")
    })
}

// Função para criar o botão flutuante
function createFloatingRestartButton() {
    if (document.getElementById('luafast-floating-restart')) return;
    
    const floatingButton = document.createElement('button');
    floatingButton.id = 'luafast-floating-restart';
    floatingButton.textContent = 'Restart Steam';
    floatingButton.style.position = 'fixed';
    floatingButton.style.bottom = '20px';
    floatingButton.style.left = '20px';
    floatingButton.style.zIndex = '10000';
    floatingButton.style.background = '#1b2838';
    floatingButton.style.color = '#ffffff';
    floatingButton.style.border = '1px solid #67c1f5';
    floatingButton.style.borderRadius = '4px';
    floatingButton.style.padding = '8px 16px';
    floatingButton.style.cursor = 'pointer';
    floatingButton.style.fontFamily = 'sans-serif';
    floatingButton.style.fontSize = '14px';
    floatingButton.style.boxShadow = '0 2px 10px rgba(0,0,0,0.5)';
    floatingButton.style.transition = 'all 0.2s ease';
    
    floatingButton.addEventListener('mouseenter', () => {
        floatingButton.style.background = '#67c1f5';
        floatingButton.style.color = '#1b2838';
        floatingButton.style.transform = 'scale(1.05)';
    });
    
    floatingButton.addEventListener('mouseleave', () => {
        floatingButton.style.background = '#1b2838';
        floatingButton.style.color = '#ffffff';
        floatingButton.style.transform = 'scale(1)';
    });

    floatingButton.addEventListener('click', async () => {
        const originalText = floatingButton.textContent;
        floatingButton.style.background = '#3a6b8a';
        floatingButton.style.cursor = 'wait';
        floatingButton.textContent = 'Iniciando reinício...';
        
        try {
            const result = await __call_server_method__('restartSteam', {});
            
            if (result && result.success) {
                floatingButton.textContent = 'Reinício iniciado!';
                floatingButton.style.background = '#2d5c2d';
                
                setTimeout(() => {
                    if (typeof ShowAlertDialog === 'function') {
                        ShowAlertDialog(
                            'Reinício do Steam',
                            'O processo de reinício foi iniciado em uma janela separada.\n\nO Steam será fechado e reiniciado automaticamente.\n\nA janela do prompt fechará sozinha quando o processo estiver completo.'
                        );
                    } else {
                        alert('Reinício do Steam iniciado! O Steam será fechado e reiniciado automaticamente.');
                    }
                }, 500);
                
                setTimeout(() => {
                    floatingButton.textContent = originalText;
                    floatingButton.style.background = '#1b2838';
                    floatingButton.style.cursor = 'pointer';
                }, 3000);
            } else {
                throw new Error(result?.error || 'Erro desconhecido ao iniciar o reinício');
            }
        } catch (error) {
            console.error('Erro ao reiniciar Steam:', error);
            floatingButton.textContent = 'Erro!';
            floatingButton.style.background = '#8b2d2d';
            
            setTimeout(() => {
                if (typeof ShowAlertDialog === 'function') {
                    ShowAlertDialog(
                        'Erro no Reinício',
                        'Não foi possível iniciar o processo de reinício do Steam.\n\nErro: ' + error.message
                    );
                } else {
                    alert('Erro ao reiniciar Steam: ' + error.message);
                }
            }, 500);
            
            setTimeout(() => {
                floatingButton.textContent = originalText;
                floatingButton.style.background = '#1b2838';
                floatingButton.style.cursor = 'pointer';
            }, 3000);
        }
    });
    
    document.body.appendChild(floatingButton);
}

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', createFloatingRestartButton);
} else {
    createFloatingRestartButton();
}

// Observador menos agressivo para o botão flutuante
new MutationObserver(() => {
    if (!document.getElementById('luafast-floating-restart')) {
        // Pequeno delay para evitar criação múltipla
        setTimeout(createFloatingRestartButton, 100);
    }
}).observe(document.body, {
    childList: true,
    subtree: false // Apenas observar filhos diretos do body
});

ExecutePluginModule();
