let reportsLoaded = false;
let reportsList = [];
let activeReportDetails = null;
let activeReportMode = 'list';

let reportDraft = {
    type: 'Incident',
    title: '',
    narrative: '',
    officers: [],
    peds: [],
    charges: [],
    photos: []
};

let editingReportId = null;
let tabletClockInterval = null;
let personnelDatabase = [];
let personnelLoaded = false;
let chargeResults = [];
let pedReportsCache = {};
let selectedProfilePed = null;
let selectedProfilePicturePosition = {
    x: 50,
    y: 5,
    zoom: 100
};

let selectedBackgroundPosition = {
    x: 50,
    y: 50,
    zoom: 100
};

let tabletAlertTimeout = null;
let currentTabletAlert = null;
let selectedDecodeVehicle = null;
let decodeProgressInterval = null;
let decodeInProgress = false;
let dispatchAlerts = [];
let database = {
    peds: [],
    vehicles: [],
    callouts: [],
    personnel: {},
    onDuty: false
};

let activeTab = 'home';

const app = document.getElementById('app');
const content = document.getElementById('content');
const searchInput = document.getElementById('search');

function nuiCallback(name, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    });
}

// function playSound(type) {
//     nuiCallback('playSound', {
//         sound: type
//     });
// }

function playSound(type = 'buttonClick') {
    const sounds = {
        open: {
            audioName: 'NAV_UP_DOWN',
            audioRef: 'HUD_FRONTEND_DEFAULT_SOUNDSET'
        },
        close: {
            audioName: 'BACK',
            audioRef: 'HUD_FRONTEND_DEFAULT_SOUNDSET'
        },
        click: {
            audioName: 'NAV_UP_DOWN',
            audioRef: 'HUD_FRONTEND_DEFAULT_SOUNDSET'
        },
        buttonClick: {
            audioName: 'NAV_UP_DOWN',
            audioRef: 'HUD_FRONTEND_DEFAULT_SOUNDSET'
        },
        notify: {
            audioName: 'ATM_WINDOW',
            audioRef: 'HUD_FRONTEND_DEFAULT_SOUNDSET'
        }
    };

    const sound = sounds[type] || sounds.buttonClick;

    fetch(`https://${GetParentResourceName()}/playTabletSound`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(sound)
    }).catch(() => {});
}

function runTabletAction(action) {
    playSound('click');
    nuiCallback('tabletAction', { action });
}

window.addEventListener('message', (event) => {
    const payload = event.data;

    if (payload.action === 'openDatabase') {
        database = payload.data || database;
        dispatchAlerts = payload.dispatch || [];

        app.classList.remove('hidden');

        updateTabletStatus();
        updateTabletUnitStatus(database.unit_status || database.unitStatus || '10-8');

        if (!tabletClockInterval) {
            tabletClockInterval = setInterval(() => {
                updateTabletStatus();
                updateTabletUnitStatus(database.unit_status || database.unitStatus || '10-8');
            }, 1000);
        }

        playSound('open');
        render();
    }

    if (payload.action === 'reportsList') {
        reportsList = payload.reports || [];
        activeReportMode = 'list';
        renderReports();
    }

    if (payload.action === 'reportDetails') {
        activeReportDetails = payload.details;
        activeReportMode = 'details';
        renderReports();
    }

    if (payload.action === 'chargeResults') {
        chargeResults = payload.charges || [];
        renderChargeResults(chargeResults);
    }

    if (payload.action === 'pedPreviousReports') {
        pedReportsCache[payload.ped_identifier] = payload.reports || [];
        render();
    }

    if (payload.action === 'personnelDatabase') {
        personnelDatabase = payload.personnel || payload.data || [];
        database.personnel = personnelDatabase;

        if (activeTab === 'reports' && activeReportMode === 'create') {
            renderCreateReport();
            return;
        }

        if (activeTab === 'personnel') {
            renderPersonnel();
            return;
        }

        return;
    }

    if (payload.action === 'tabletCallAlert') {
        showTabletCallAlert(payload.data || {});
    }

    if (payload.action === 'receiveNearbyDecodeVehicles') {
        openDecodeModal(payload.vehicles || []);
    }

    if (payload.action === 'decodeFinished') {
        finishDecodeUI(payload.success, payload.message);
    }

    if (payload.action === 'receiveERSPersonnelDatabase') {
        personnelDatabase = payload.data || [];
        database.personnel = personnelDatabase;

        if (activeTab === 'reports' && activeReportMode === 'create') {
            renderCreateReport();
            return;
        }

        if (activeTab === 'personnel') {
            renderPersonnel();
            return;
        }
    }

    if (payload.action === 'closeDatabase') {
        app.classList.add('hidden');
    }
});

document.getElementById('closeBtn').addEventListener('click', closeDatabase);

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') closeDatabase();
});

document.querySelectorAll('.tab').forEach((btn) => {
    btn.addEventListener('click', () => {
        playSound('click');

        document.querySelectorAll('.tab').forEach((b) => b.classList.remove('active'));
        btn.classList.add('active');

        activeTab = btn.dataset.tab;
        searchInput.value = '';
        render();
    });
});

document.querySelectorAll('.tablet-action-btn').forEach((btn) => {
    btn.addEventListener('click', () => {
        const action = btn.dataset.action;

        playSound('click');

        // 👇 ADD YOUR HOME HANDLER HERE
        if (action === 'homeScreen') {
            activeTab = 'home';

            document.querySelectorAll('.tab').forEach((b) => b.classList.remove('active'));
            const homeTab = document.querySelector('.tab[data-tab="home"]');
            if (homeTab) homeTab.classList.add('active');

            render();
            return;
        }

        // everything else still goes to server
        nuiCallback('tabletAction', { action });
    });
});

document.addEventListener('click', (e) => {
    if (e.target.tagName === 'SUMMARY') {
        playSound('click');
    }
});

searchInput.addEventListener('input', render);

document.getElementById('refreshDataBtn').addEventListener('click', () => {
    playSound('click');
    nuiCallback('refreshDatabase');
});

document.getElementById('cancelDecodeBtn').addEventListener('click', () => {
    if (decodeProgressInterval) {
        clearInterval(decodeProgressInterval);
        decodeProgressInterval = null;
    }

    decodeInProgress = false;
    selectedDecodeVehicle = null;

    nuiCallback('cancelVehicleDecodeSound');

    document.getElementById('decodeModal').classList.add('hidden');

    playSound('click');
});

document.getElementById('confirmDecodeBtn').addEventListener('click', () => {
    if (!selectedDecodeVehicle || decodeInProgress) return;

    playSound('click');
    startDecodeUI(selectedDecodeVehicle);
});

document.getElementById('cancelConfirmDecodeBtn').addEventListener('click', () => {
    selectedDecodeVehicle = null;

    document.getElementById('decodeConfirmBox')?.classList.add('hidden');

    nuiCallback('getNearbyDecodeVehicles');

    playSound('close');
});

// document.querySelectorAll('.unit-status-btn').forEach((btn) => {
//     btn.addEventListener('click', () => {
//         const status = btn.dataset.status;

//         database.unit_status = status;

//         updateTabletUnitStatus(status);

//         playSound('click');

//         nuiCallback('setUnitStatus', {
//             status: status
//         });
//     });
// });

document.getElementById('tabletAlert').addEventListener('click', () => {
    if (!currentTabletAlert) return;

    playSound('click');

    nuiCallback('tabletAction', {
        action: 'acceptCallout'
    });

    document.getElementById('tabletAlert').classList.add('hidden');
    currentTabletAlert = null;

    if (tabletAlertTimeout) {
        clearTimeout(tabletAlertTimeout);
        tabletAlertTimeout = null;
    }
});


function openDecodeModal(vehicles) {
    const modal = document.getElementById('decodeModal');
    const list = document.getElementById('decodeVehicleList');
    const confirmBox = document.getElementById('decodeConfirmBox');
    const progressBox = document.getElementById('decodeProgressBox');
    const progressFill = document.getElementById('decodeProgressFill');

    if (!modal || !list || !confirmBox || !progressBox || !progressFill) return;

    selectedDecodeVehicle = null;
    decodeInProgress = false;

    confirmBox.classList.add('hidden');
    progressBox.classList.add('hidden');
    progressFill.style.width = '0%';

    if (!vehicles.length) {
        list.innerHTML = `<div class="grid-item full">No nearby vehicles found</div>`;
    } else {
        list.innerHTML = vehicles.map((v, index) => `
            <button class="decode-vehicle-btn" data-index="${index}">
                <div class="decode-vehicle-icon">
                    <i class="fa-solid fa-car"></i>
                </div>

                <div class="decode-vehicle-info">
                    <strong>${text(v.plate || 'UNKNOWN')}</strong>
                    <small>${text(v.label || 'Vehicle')} | ${text(v.distance)}m away</small>
                </div>
            </button>
        `).join('');
    }

    modal.dataset.vehicles = encodeURIComponent(JSON.stringify(vehicles));
    modal.classList.remove('hidden');

    document.querySelectorAll('.decode-vehicle-btn').forEach((btn) => {
        btn.addEventListener('click', () => {
            if (decodeInProgress) return;

            const storedVehicles = JSON.parse(decodeURIComponent(modal.dataset.vehicles || '[]'));
            selectedDecodeVehicle = storedVehicles[Number(btn.dataset.index)];

            if (!selectedDecodeVehicle) return;

            showDecodeConfirm(selectedDecodeVehicle);
        });
    });

    playSound('click');
}

function showDecodeConfirm(vehicleData) {
    const list = document.getElementById('decodeVehicleList');
    const confirmBox = document.getElementById('decodeConfirmBox');
    const confirmPlate = document.getElementById('decodeConfirmPlate');

    if (!list || !confirmBox || !confirmPlate) return;

    list.innerHTML = `
        <div class="grid-item full">
            Selected Vehicle<br>
            <strong>${text(vehicleData.plate || 'UNKNOWN')}</strong>
        </div>
    `;

    confirmPlate.textContent = `Decode ${vehicleData.plate || 'UNKNOWN'} and attempt to unlock it?`;
    confirmBox.classList.remove('hidden');

    playSound('click');
}

function startDecodeUI(vehicleData) {
    const confirmBox = document.getElementById('decodeConfirmBox');
    const list = document.getElementById('decodeVehicleList');
    const progressBox = document.getElementById('decodeProgressBox');
    const progressFill = document.getElementById('decodeProgressFill');

    if (!list || !progressBox || !progressFill) return;

    decodeInProgress = true;

    if (confirmBox) confirmBox.classList.add('hidden');

    list.innerHTML = `
        <div class="grid-item full">
            Selected Plate: <strong>${text(vehicleData.plate || 'UNKNOWN')}</strong>
        </div>
    `;

    progressBox.classList.remove('hidden');
    progressFill.style.width = '0%';

    let progress = 0;

    if (decodeProgressInterval) {
        clearInterval(decodeProgressInterval);
    }

    decodeProgressInterval = setInterval(() => {
        progress += 2.5;
        progressFill.style.width = `${Math.min(progress, 100)}%`;

        if (progress >= 100) {
            clearInterval(decodeProgressInterval);
            decodeProgressInterval = null;
        }
    }, 100);

    playSound('click');

    nuiCallback('startVehicleDecode', {
        netId: vehicleData.netId,
        plate: vehicleData.plate
    });
}

function finishDecodeUI(success, message) {
    const progressBox = document.getElementById('decodeProgressBox');
    const progressFill = document.getElementById('decodeProgressFill');
    const list = document.getElementById('decodeVehicleList');

    if (decodeProgressInterval) {
        clearInterval(decodeProgressInterval);
        decodeProgressInterval = null;
    }

    if (progressFill) {
        progressFill.style.width = '100%';
    }

    decodeInProgress = false;

    if (list) {
        list.innerHTML = `
            <div class="grid-item full">
                <strong>${success ? 'Decode Successful' : 'Decode Failed'}</strong><br>
                ${text(message || '')}
            </div>
        `;
    }

    playSound(success ? 'open' : 'close');

    setTimeout(() => {
        document.getElementById('decodeModal')?.classList.add('hidden');

        if (progressBox) progressBox.classList.add('hidden');
        if (progressFill) progressFill.style.width = '0%';
    }, 1200);
}

function showTabletCallAlert(data) {
    const alertBox = document.getElementById('tabletAlert');
    const alertTitle = document.getElementById('tabletAlertTitle');
    const alertBody = document.getElementById('tabletAlertBody');

    if (!alertBox || !alertTitle || !alertBody) return;

    currentTabletAlert = data || {};

    alertTitle.textContent = data.title || 'Incoming 911 Call';

    alertBody.innerHTML = `
        <strong>${text(data.callName || 'Unknown Call')}</strong><br>
        ${text(data.location || 'Unknown Location')}
    `;

    alertBox.classList.remove('hidden');

    // only play sound if tablet is open
    if (!app.classList.contains('hidden')) {
        playSound('open');
    }

    if (tabletAlertTimeout) {
        clearTimeout(tabletAlertTimeout);
    }

    tabletAlertTimeout = setTimeout(() => {
        alertBox.classList.add('hidden');
        currentTabletAlert = null;
        tabletAlertTimeout = null;
    }, 20000);
}

function vehicleFlagTiles(flags) {
    const flagList = [
        {
            icon: 'fa-shield-halved',
            label: 'Insured',
            value: flags.insurance === true,
            clear: true
        },
        {
            icon: 'fa-car-burst',
            label: 'Stolen',
            value: flags.stolen === true
        },
        {
            icon: 'fa-bullhorn',
            label: 'BOLO',
            value: flags.bolo === true
        },
        {
            icon: 'fa-flag',
            label: 'Flagged',
            value: flags.flagged === true
        },
        {
            icon: 'fa-triangle-exclamation',
            label: 'Wanted',
            value: flags.wanted === true
        }
    ];

    const active = flagList.filter((f) => f.value === true);

    if (!active.length) {
        return `
            <div class="icon-tile clear">
                <i class="fa-solid fa-circle-check"></i>
                <span>No Active Vehicle Flags</span>
            </div>
        `;
    }

    return active.map((f) => {
        if (f.clear) {
            return `
                <div class="icon-tile clear">
                    <i class="fa-solid ${f.icon}"></i>
                    <span>${text(f.label)}</span>
                </div>
            `;
        }

        return flagTile(f.icon, f.label, true);
    }).join('');
}

function closeDatabase() {
    app.classList.add('hidden');

    // stop clock
    if (tabletClockInterval) {
        clearInterval(tabletClockInterval);
        tabletClockInterval = null;
    }

    playSound('close');

    nuiCallback('closeDatabase');
}

function updateSearchVisibility() {
    const searchRow = document.querySelector('.search-row');

    if (!searchRow) return;

    if (activeTab === 'home') {
        searchRow.classList.add('hidden');
    } else {
        searchRow.classList.remove('hidden');
    }
}

function text(value) {
    if (value === true) return 'Yes';
    if (value === false) return 'No';
    if (value === null || value === undefined || value === '') return 'N/A';
    return String(value);
}

function badge(value) {
    const bool = value === true || value === 'true' || value === 'Yes';
    return `<span class="badge ${bool ? 'bad' : 'good'}">${bool ? 'Yes' : 'No'}</span>`;
}

function normalBadge(value) {
    const bool = value === true || value === 'true' || value === 'Yes';
    return `<span class="badge ${bool ? 'good' : 'bad'}">${bool ? 'Yes' : 'No'}</span>`;
}

function row(label, value) {
    return `<div class="row"><span>${label}</span><strong>${text(value)}</strong></div>`;
}

function matchesSearch(obj) {
    const q = searchInput.value.toLowerCase().trim();
    if (!q) return true;
    return JSON.stringify(obj).toLowerCase().includes(q);
}

function render() {
    updateSearchVisibility();

    if (activeTab === 'home') renderHome();
    if (activeTab === 'peds') renderPeds();
    if (activeTab === 'vehicles') renderVehicles();
    if (activeTab === 'callouts') renderCallouts();
    if (activeTab === 'personnel') renderPersonnel();
    if (activeTab === 'services') renderServices();
    if (activeTab === 'dispatch') renderDispatch();
    if (activeTab === 'reports') {
    if (!reportsLoaded) {
            reportsLoaded = true;
            nuiCallback('getReports');
        }

        renderReports();
    }
}

function updateTabletUnitStatus(status) {
    const text = document.getElementById('tabletStatusText');
    const icon = document.getElementById('tabletStatusIcon');
    const container = document.querySelector('.status-unit');

    if (!text || !icon || !container) return;

    text.textContent = status || '10-8';

    container.classList.remove('offline', 'busy', 'available');

    if (status === '10-7') {
        container.classList.add('offline');
        icon.className = 'fa-solid fa-power-off';
    } else if (status === '10-8') {
        container.classList.add('available');
        icon.className = 'fa-solid fa-check';
    } else if (status === '10-6') {
        container.classList.add('busy');
        icon.className = 'fa-solid fa-pause';
    } else if (status === 'Traffic') {
        container.classList.add('busy');
        icon.className = 'fa-solid fa-car';
    } else if (status === 'Signal 11') {
        container.classList.add('busy');
        icon.className = 'fa-solid fa-user-shield';
    } else if (status === 'Signal 41') {
        container.classList.add('busy');
        icon.className = 'fa-solid fa-user';
    } else if (status === 'Signal 42') {
        container.classList.add('busy');
        icon.className = 'fa-solid fa-pause';
    } else {
        container.classList.add('available');
        icon.className = 'fa-solid fa-circle';
    }
}

function renderHome() {
    const bg = database.tablet_background || '';

    content.innerHTML = `
        <div
            class="home-screen"
            style="
                ${bg ? `background-image: url('${bg}');` : ''}
                background-position: ${database.tablet_background_position_x || 50}% ${database.tablet_background_position_y || 50}%;
                background-size: ${database.tablet_background_zoom || 100}%;
            "
        >
        <div class="home-overlay">

            <div class="home-header">

                <div class="home-header-text">
                    <h2><i class="fa-solid fa-network-wired"></i> SYSTEM COMMAND</h2>
                    <p>Welcome, ${text(database.characterName || 'Unknown')}</p>
                </div>
            </div>

            <div class="home-status-panel">
                <label>
                    <i class="fa-solid fa-signal"></i>
                    Unit Status
                </label>

                <select id="homeStatusSelect">
                    <option value="10-6">10-6</option>
                    <option value="10-8">10-8</option>
                    <option value="10-7">10-7</option>
                    <option value="Traffic">TRAFFIC</option>
                    <option value="Signal 11">Signal 11</option>
                    <option value="Signal 41">Signal 41</option>
                    <option value="Signal 42">Signal 42</option>
                </select>
            </div>

            <div class="home-grid">
                    <button class="home-tile" data-tab-go="services">
                        <i class="fa-solid fa-screwdriver-wrench"></i>
                        <span>SERVICES</span>
                    </button>

                    <button class="home-tile" data-tab-go="dispatch">
                        <i class="fa-solid fa-radio"></i>
                        <span>DISPATCH</span>
                    </button>

                    <button class="home-tile" data-tab-go="peds">
                        <i class="fa-solid fa-user"></i>
                        <span>PROFILES</span>
                    </button>

                    <button class="home-tile" data-tab-go="vehicles">
                        <i class="fa-solid fa-car"></i>
                        <span>VEHICLES</span>
                    </button>

                    <button class="home-tile" data-tab-go="callouts">
                        <i class="fa-solid fa-bullhorn"></i>
                        <span>CALLOUTS</span>
                    </button>

                    <button class="home-tile" data-tab-go="personnel">
                        <i class="fa-solid fa-users"></i>
                        <span>PERSONNEL</span>
                    </button>

                    <button class="home-tile" data-tab-go="reports">
                        <i class="fa-solid fa-file-lines"></i>
                        <span>REPORTS</span>
                    </button>

                    <button class="home-tile" data-action="requestCallout">
                        <i class="fa-solid fa-bullhorn"></i>
                        <span>REQUEST CALL</span>
                    </button>

                    <button class="home-tile" data-action="toggleCallouts">
                        <i class="fa-solid fa-toggle-on"></i>
                        <span>TOGGLE CALLS</span>
                    </button>

                    <button class="home-tile" data-action="completeCallout">
                        <i class="fa-solid fa-flag-checkered"></i>
                        <span>COMPLETE CALL</span>
                    </button>

                    <button class="home-tile" data-action="speedzone">
                        <i class="fa-solid fa-gauge-high"></i>
                        <span>SPEEDZONE</span>
                    </button>

                    <button class="home-tile" data-action="placeobjects">
                        <i class="fa-solid fa-box"></i>
                        <span>PLACE OBJECT</span>
                    </button>

                    <button class="home-tile" id="openDecodeBtn">
                        <i class="fa-solid fa-microchip"></i>
                        <span>VEHICLE DECODER</span>
                    </button>

                    <button class="home-tile" id="setBackgroundBtn">
                        <i class="fa-solid fa-image"></i>
                        <span>WALLPAPER</span>
                    </button>
                </div>
            </div>
        </div>
    `;

    const openDecodeBtn = document.getElementById('openDecodeBtn');

    if (openDecodeBtn) {
        openDecodeBtn.addEventListener('click', () => {
            playSound('click');

            nuiCallback('getNearbyDecodeVehicles');
        });
    }

    document.querySelectorAll('[data-tab-go]').forEach((btn) => {
        btn.addEventListener('click', () => {
            activeTab = btn.dataset.tabGo;

            document.querySelectorAll('.tab').forEach((b) => b.classList.remove('active'));
            const tabBtn = document.querySelector(`.tab[data-tab="${activeTab}"]`);
            if (tabBtn) tabBtn.classList.add('active');

            playSound('click');
            render();
        });
    });

    document.querySelectorAll('[data-action]').forEach((btn) => {
        btn.addEventListener('click', () => {
            const action = btn.dataset.action;

            playSound('click');

            nuiCallback('tabletAction', { action });

            if (action === 'speedzone' || action === 'placeobjects') {
                closeDatabase();
            }
        });
    });

    document.getElementById('setBackgroundBtn').addEventListener('click', () => {
        openBackgroundModal();
    });

    const homeStatusSelect = document.getElementById('homeStatusSelect');

    if (homeStatusSelect) {
        homeStatusSelect.value = database.unit_status || '10-8';

        homeStatusSelect.addEventListener('change', () => {
            const status = homeStatusSelect.value;

            database.unit_status = status;

            updateTabletUnitStatus(status);

            playSound('click');

            nuiCallback('setUnitStatus', {
                status: status
            });
        });
    }
}

function openBackgroundModal() {
    const modal = document.getElementById('backgroundModal');
    const input = document.getElementById('backgroundInput');
    const preview = document.getElementById('backgroundPreview');
    const noPreview = document.getElementById('backgroundNoPreview');
    const zoomSlider = document.getElementById('backgroundZoomSlider');

    if (!modal || !input || !preview || !noPreview || !zoomSlider) return;

    selectedBackgroundPosition = {
        x: Number(database.tablet_background_position_x || 50),
        y: Number(database.tablet_background_position_y || 50),
        zoom: Number(database.tablet_background_zoom || 100)
    };

    input.value = database.tablet_background || '';
    zoomSlider.value = selectedBackgroundPosition.zoom;

    if (input.value) {
        preview.src = input.value;
        preview.classList.remove('hidden');
        noPreview.classList.add('hidden');
    } else {
        preview.src = '';
        preview.classList.add('hidden');
        noPreview.classList.remove('hidden');
    }

    updateBackgroundPreviewTransform();

    modal.classList.remove('hidden');
    enableBackgroundEditorDrag();

    playSound('click');
}

function updateBackgroundPreviewTransform() {
    const preview = document.getElementById('backgroundPreview');
    if (!preview) return;

    preview.style.objectPosition = `${selectedBackgroundPosition.x}% ${selectedBackgroundPosition.y}%`;
    preview.style.transform = `scale(${selectedBackgroundPosition.zoom / 100})`;
}

function enableBackgroundEditorDrag() {
    const frame = document.getElementById('backgroundEditorFrame');
    const img = document.getElementById('backgroundPreview');

    if (!frame || !img) return;

    let dragging = false;

    const updatePosition = (clientX, clientY) => {
        const rect = frame.getBoundingClientRect();

        let x = ((clientX - rect.left) / rect.width) * 100;
        let y = ((clientY - rect.top) / rect.height) * 100;

        x = Math.max(0, Math.min(100, x));
        y = Math.max(0, Math.min(100, y));

        selectedBackgroundPosition.x = Math.round(x);
        selectedBackgroundPosition.y = Math.round(y);

        updateBackgroundPreviewTransform();
    };

    frame.onmousedown = (e) => {
        dragging = true;
        updatePosition(e.clientX, e.clientY);
    };

    window.onmousemove = (e) => {
        if (!dragging) return;
        updatePosition(e.clientX, e.clientY);
    };

    window.onmouseup = () => {
        dragging = false;
    };

    frame.onwheel = (e) => {
        e.preventDefault();

        const currentZoom = Number(selectedBackgroundPosition.zoom || 100);
        const nextZoom = e.deltaY < 0
            ? Math.min(currentZoom + 5, 250)
            : Math.max(currentZoom - 5, 100);

        selectedBackgroundPosition.zoom = nextZoom;

        const slider = document.getElementById('backgroundZoomSlider');
        if (slider) slider.value = nextZoom;

        updateBackgroundPreviewTransform();
    };
}

document.getElementById('backgroundInput').addEventListener('input', (e) => {
    const url = e.target.value.trim();
    const preview = document.getElementById('backgroundPreview');
    const noPreview = document.getElementById('backgroundNoPreview');

    if (url) {
        preview.src = url;
        preview.classList.remove('hidden');
        noPreview.classList.add('hidden');
    } else {
        preview.src = '';
        preview.classList.add('hidden');
        noPreview.classList.remove('hidden');
    }

    updateBackgroundPreviewTransform();
});

document.getElementById('backgroundZoomSlider').addEventListener('input', (e) => {
    selectedBackgroundPosition.zoom = Number(e.target.value || 100);
    updateBackgroundPreviewTransform();
});

document.getElementById('saveBackgroundBtn').addEventListener('click', () => {
    const url = document.getElementById('backgroundInput').value.trim();

    database.tablet_background = url;
    database.tablet_background_position_x = selectedBackgroundPosition.x;
    database.tablet_background_position_y = selectedBackgroundPosition.y;
    database.tablet_background_zoom = selectedBackgroundPosition.zoom;

    nuiCallback('saveTabletBackground', {
        url,
        position_x: selectedBackgroundPosition.x,
        position_y: selectedBackgroundPosition.y,
        zoom: selectedBackgroundPosition.zoom
    });

    document.getElementById('backgroundModal').classList.add('hidden');

    playSound('open');
    renderHome();
});

document.getElementById('cancelBackgroundBtn').addEventListener('click', () => {
    document.getElementById('backgroundModal').classList.add('hidden');
    playSound('click');
});

function formatDateTime(value) {
    if (!value) return 'N/A';

    let date;

    // oxmysql sometimes sends timestamps as milliseconds
    if (typeof value === 'number') {
        date = new Date(value);
    } else if (/^\d+$/.test(String(value))) {
        date = new Date(Number(value));
    } else {
        date = new Date(value);
    }

    if (isNaN(date.getTime())) return text(value);

    return date.toLocaleString([], {
        month: '2-digit',
        day: '2-digit',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
    });
}

function openPhotoViewer(url, caption) {
    const modal = document.getElementById('photoViewerModal');
    const img = document.getElementById('photoViewerImage');
    const cap = document.getElementById('photoViewerCaption');

    if (!modal || !img || !cap) return;

    img.src = url || '';
    cap.textContent = caption || 'Evidence Photo';

    modal.classList.remove('hidden');
    playSound('click');
}

document.getElementById('closePhotoViewerBtn').addEventListener('click', () => {
    document.getElementById('photoViewerModal').classList.add('hidden');
    document.getElementById('photoViewerImage').src = '';
    playSound('click');
});

function updateProfilePicturePreviewTransform() {
    const preview = document.getElementById('profilePicPreview');
    if (!preview) return;

    preview.style.objectPosition = `${selectedProfilePicturePosition.x}% ${selectedProfilePicturePosition.y}%`;
    preview.style.transform = `scale(${selectedProfilePicturePosition.zoom / 100})`;
}

function enableProfilePictureEditorDrag() {
    const frame = document.getElementById('profilePictureEditorFrame');
    const img = document.getElementById('profilePicPreview');

    if (!frame || !img) return;

    let dragging = false;

    const updatePosition = (clientX, clientY) => {
        const rect = frame.getBoundingClientRect();

        let x = ((clientX - rect.left) / rect.width) * 100;
        let y = ((clientY - rect.top) / rect.height) * 100;

        x = Math.max(0, Math.min(100, x));
        y = Math.max(0, Math.min(100, y));

        selectedProfilePicturePosition.x = Math.round(x);
        selectedProfilePicturePosition.y = Math.round(y);

        updateProfilePicturePreviewTransform();
    };

    frame.onmousedown = (e) => {
        dragging = true;
        updatePosition(e.clientX, e.clientY);
    };

    window.onmousemove = (e) => {
        if (!dragging) return;
        updatePosition(e.clientX, e.clientY);
    };

    window.onmouseup = () => {
        dragging = false;
    };

    frame.onwheel = (e) => {
        e.preventDefault();

        const currentZoom = Number(selectedProfilePicturePosition.zoom || 100);
        const nextZoom = e.deltaY < 0
            ? Math.min(currentZoom + 5, 250)
            : Math.max(currentZoom - 5, 100);

        selectedProfilePicturePosition.zoom = nextZoom;

        const slider = document.getElementById('profilePictureZoomSlider');
        if (slider) slider.value = nextZoom;

        updateProfilePicturePreviewTransform();
    };
}

document.getElementById('profilePicInput').addEventListener('input', (e) => {
    const url = e.target.value.trim();
    const preview = document.getElementById('profilePicPreview');
    const noPreview = document.getElementById('profilePicNoPreview');

    if (url) {
        preview.src = url;
        preview.classList.remove('hidden');
        noPreview.classList.add('hidden');
    } else {
        preview.src = '';
        preview.classList.add('hidden');
        noPreview.classList.remove('hidden');
    }

    updateProfilePicturePreviewTransform();
});

document.getElementById('profilePictureZoomSlider').addEventListener('input', (e) => {
    selectedProfilePicturePosition.zoom = Number(e.target.value || 100);
    updateProfilePicturePreviewTransform();
});

document.getElementById('cancelProfilePicBtn').addEventListener('click', () => {
    document.getElementById('profilePicModal').classList.add('hidden');
    selectedProfilePed = null;
    playSound('click');
});

document.getElementById('saveProfilePicBtn').addEventListener('click', () => {
    if (!selectedProfilePed) return;

    const url = document.getElementById('profilePicInput').value.trim();
    if (!url) return;

    selectedProfilePed.ProfilePicture = url;
    selectedProfilePed.ProfilePicturePositionX = selectedProfilePicturePosition.x;
    selectedProfilePed.ProfilePicturePositionY = selectedProfilePicturePosition.y;
    selectedProfilePed.ProfilePictureZoom = selectedProfilePicturePosition.zoom;

    nuiCallback('updateProfilePicture', {
        ped_identifier: getPedIdentifierJs(selectedProfilePed),
        citizenid: selectedProfilePed.citizenid || null,
        profileType: selectedProfilePed.profileType || 'NPC',
        profilePicture: url,
        position_x: selectedProfilePicturePosition.x,
        position_y: selectedProfilePicturePosition.y,
        zoom: selectedProfilePicturePosition.zoom,
        pedData: selectedProfilePed
    });

    database.peds = (database.peds || []).map((p) => {
        const sameProfile =
            getPedIdentifierJs(p) === getPedIdentifierJs(selectedProfilePed) ||
            (p.citizenid && selectedProfilePed.citizenid && p.citizenid === selectedProfilePed.citizenid);

        if (sameProfile) {
            return {
                ...p,
                ProfilePicture: url,
                ProfilePicturePositionX: selectedProfilePicturePosition.x,
                ProfilePicturePositionY: selectedProfilePicturePosition.y,
                ProfilePictureZoom: selectedProfilePicturePosition.zoom
            };
        }

        return p;
    });

    document.getElementById('profilePicModal').classList.add('hidden');
    selectedProfilePed = null;

    playSound('open');
    renderPeds();
});

function renderPeds() {
    const peds = (database.peds || []).filter(matchesSearch);

    if (!peds.length) {
        content.innerHTML = `<div class="card"><h2><i class="fa-solid fa-user"></i> No Profile Records</h2></div>`;
        return;
    }

    content.innerHTML = `<div class="grid">` + peds.map((p) => {
        const flags = p.FlagsOrMarkers || {};
        const hasAlert = flags.wanted_person || flags.active_warrant || flags.armed_and_dangerous || p.Wanted_Person;

        const profilePic = p.ProfilePicture && p.ProfilePicture !== 'N/A'
            ? p.ProfilePicture
            : '';

        const profilePosX = p.ProfilePicturePositionX || 50;
        const profilePosY = p.ProfilePicturePositionY || 5;
        const profileZoom = p.ProfilePictureZoom || 100;

        return `
            <div class="card ped-card profile-id-card">
                <details class="profile-details">
                    <summary class="profile-summary profile-id-summary">
                        <div class="profile-card-photo-frame">
                            <span class="status-light profile-photo-status ${hasAlert ? 'alert' : 'clear'}"></span>

                            ${
                                profilePic
                                    ? `<img
                                        src="${profilePic}"
                                        style="
                                            object-position: ${profilePosX}% ${profilePosY}%;
                                            transform: scale(${profileZoom / 100});
                                        "
                                    />`
                                    : `<div class="profile-card-photo-placeholder">
                                        <i class="fa-solid ${p.profileType === 'Player' ? 'fa-id-card' : 'fa-user'}"></i>
                                    </div>`
                            }
                        </div>

                        <div class="profile-card-info">
                            <div class="profile-card-top">
                                <div>
                                    <div class="profile-card-name">
                                        ${text(p.FirstName)} ${text(p.LastName)}
                                    </div>

                                </div>

                                <span class="profile-badge ${p.profileType === 'Player' ? 'player' : 'npc'}">
                                    ${p.profileType || 'NPC'}
                                </span>
                            </div>

                            <div class="profile-card-meta">
                                <span>
                                    <i class="fa-solid fa-calendar"></i>
                                    ${text(p.DOB || 'N/A')}
                                </span>

                                <span>
                                    <i class="fa-solid fa-venus-mars"></i>
                                    ${text(p.Gender || 'N/A')}
                                </span>
                            </div>

                            <div class="profile-card-address">
                                <i class="fa-solid fa-house"></i>
                                <span>${text(p.Address || 'N/A')}</span>
                            </div>

                            <div class="profile-card-footer">
                                <span class="profile-alert-tag ${hasAlert ? 'alert' : 'clear'}">
                                    <i class="fa-solid ${hasAlert ? 'fa-triangle-exclamation' : 'fa-circle-check'}"></i>
                                    ${hasAlert ? 'FLAGGED' : 'CLEAR'}
                                </span>

                                <span class="profile-expand-icon">
                                    <i class="fa-solid fa-chevron-down"></i>
                                </span>
                            </div>
                        </div>
                    </summary>

                    <div class="profile-expanded-content">
                        <div class="profile-photo-wrap">
                            <div class="profile-photo-frame">
                                ${
                                    profilePic
                                        ? `<img
                                            class="profile-img-large"
                                            src="${profilePic}"
                                            style="
                                                object-position: ${profilePosX}% ${profilePosY}%;
                                                transform: scale(${profileZoom / 100});
                                            "
                                        />`
                                        : `<div class="no-profile-img">No Image</div>`
                                }
                            </div>

                            <button class="mini-action-btn update-profile-pic-btn" data-ped="${encodeURIComponent(JSON.stringify(p))}">
                                <i class="fa-solid fa-image"></i> Update Picture
                            </button>
                        </div>

                        <div class="info-grid">
                            ${gridItem('<i class="fa-solid fa-user"></i>', 'Name', `${text(p.FirstName)} ${text(p.LastName)}`)}
                            ${gridItem('<i class="fa-solid fa-calendar"></i>', 'DOB', p.DOB)}
                            ${gridItem('<i class="fa-solid fa-venus-mars"></i>', 'Gender', p.Gender)}
                            ${gridItem('<i class="fa-solid fa-flag"></i>', 'Nationality', p.Nationality)}
                            ${gridItem('<i class="fa-solid fa-phone"></i>', 'Phone', p.PhoneNumber)}
                            ${gridItem('<i class="fa-solid fa-house"></i>', 'Address', p.Address, true)}
                            ${gridItem('<i class="fa-solid fa-city"></i>', 'City / State', `${text(p.City)}, ${text(p.State)} ${text(p.PostalCode)}`)}
                            ${gridItem('<i class="fa-solid fa-id-badge"></i>', 'Citizen ID', p.citizenid || p.ped_identifier || 'N/A')}
                            ${gridItem('<i class="fa-solid fa-user-tag"></i>', 'Profile Type', p.profileType || 'N/')}
                        </div>

                        <details>
                            <summary><i class="fa-solid fa-id-badge"></i> Licenses</summary>
                            <div class="icon-grid">
                                ${iconTile('fa-car', 'Car', p.License_Car)}
                                ${iconTile('fa-motorcycle', 'Motorcycle', p.License_Bike || p.License_Bike_Is_Valid)}
                                ${iconTile('fa-plane', 'Pilot', p.License_Pilot)}
                                ${iconTile('fa-truck', 'CDL', p.License_Truck)}
                                ${iconTile('fa-ship', 'Boat', p.License_Boat || p.License_Boat_Is_Valid)}
                            </div>
                        </details>

                        <details>
                            <summary><i class="fa-solid fa-triangle-exclamation"></i> Flags / Markers</summary>
                            <div class="icon-grid">
                                ${activeFlagTiles(flags, p)}
                            </div>
                        </details>
                    </div>
                </details>
            </div>
        `;
    }).join('') + `</div>`;

    document.querySelectorAll('.update-profile-pic-btn').forEach((btn) => {
        btn.addEventListener('click', () => {
            selectedProfilePed = JSON.parse(decodeURIComponent(btn.dataset.ped));

            selectedProfilePicturePosition = {
                x: Number(selectedProfilePed.ProfilePicturePositionX || 50),
                y: Number(selectedProfilePed.ProfilePicturePositionY || 5),
                zoom: Number(selectedProfilePed.ProfilePictureZoom || 100)
            };

            const input = document.getElementById('profilePicInput');
            const preview = document.getElementById('profilePicPreview');
            const noPreview = document.getElementById('profilePicNoPreview');
            const zoomSlider = document.getElementById('profilePictureZoomSlider');
            const modal = document.getElementById('profilePicModal');

            input.value = selectedProfilePed.ProfilePicture && selectedProfilePed.ProfilePicture !== 'N/A'
                ? selectedProfilePed.ProfilePicture
                : '';

            zoomSlider.value = selectedProfilePicturePosition.zoom;

            if (input.value) {
                preview.src = input.value;
                preview.classList.remove('hidden');
                noPreview.classList.add('hidden');
            } else {
                preview.src = '';
                preview.classList.add('hidden');
                noPreview.classList.remove('hidden');
            }

            updateProfilePicturePreviewTransform();

            modal.classList.remove('hidden');
            enableProfilePictureEditorDrag();

            playSound('click');
        });
    });
}

function vehicleFlagTiles(flags) {
    const flagList = [
        {
            icon: 'fa-shield-halved',
            label: 'Insured',
            value: flags.insurance === true,
            clear: true
        },
        {
            icon: 'fa-car-burst',
            label: 'Stolen',
            value: flags.stolen === true
        },
        {
            icon: 'fa-bullhorn',
            label: 'BOLO',
            value: flags.bolo === true
        },
        {
            icon: 'fa-flag',
            label: 'Flagged',
            value: flags.flagged === true
        },
        {
            icon: 'fa-triangle-exclamation',
            label: 'Wanted',
            value: flags.wanted === true
        }
    ];

    const active = flagList.filter((f) => f.value === true);

    if (!active.length) {
        return `
            <div class="icon-tile clear">
                <i class="fa-solid fa-circle-check"></i>
                <span>No Active Vehicle Flags</span>
            </div>
        `;
    }

    return active.map((f) => {
        if (f.clear) {
            return `
                <div class="icon-tile clear">
                    <i class="fa-solid ${f.icon}"></i>
                    <span>${text(f.label)}</span>
                </div>
            `;
        }

        return `
            <div class="icon-tile alert">
                <i class="fa-solid ${f.icon}"></i>
                <span>${text(f.label)}</span>
            </div>
        `;
    }).join('');
}

function renderVehicles() {
    const vehicles = (database.vehicles || []).filter(matchesSearch);

    if (!vehicles.length) {
        content.innerHTML = `
            <div class="card">
                <h2><i class="fa-solid fa-car"></i> No Vehicle Records</h2>
                ${row('Status', 'No saved or owned vehicles found')}
            </div>
        `;
        return;
    }

    content.innerHTML = `
        <div class="grid">
            ${vehicles.map((v) => {
                const plate = v.plate || v.Plate || v.license_plate || 'UNKNOWN';

                const type = v.sourceType || v.type || 'Vehicle';
                const isPlayerOwned = type === 'Player' || type === 'Player Owned';

                const owner = v.ownerName || v.OwnerName || v.owner_name || 'Unknown';

                const make = v.make || v.Make || '';
                const model = v.model || v.vehicle_model || v.VehicleModel || '';
                const qbName = v.qbLabel || v.qb_label || v.vehicle_label || v.label || v.VehicleLabel || '';

                const displayVehicle = qbName || `${make} ${model}`.trim() || 'Unknown Vehicle';

                const citizenDisplay = isPlayerOwned
                    ? (v.citizenid || v.owner_identifier || 'N/A')
                    : 'NPC';

                let color = v.color || v.Color || 'N/A';

                const colorString = String(color).trim();
                const isNumericColor =
                    /^\d+$/.test(colorString) ||
                    /^\d+\s*\/\s*\d+$/.test(colorString);

                if (isNumericColor) {
                    color = 'N/A';
                }

                const insurance = v.insurance === true || v.insurance === 'true';
                const stolen = v.stolen === true || v.stolen === 'true';
                const bolo = v.bolo === true || v.bolo === 'true';
                const flagged = v.flagged === true || v.flagged === 'true';
                const wanted = v.wanted === true || v.wanted === 'true';

                const hasAlert = stolen || bolo || flagged || wanted;

                return `
                    <div class="card vehicle-card">
                        <details class="vehicle-details">
                            <summary class="vehicle-summary">
                                <span class="vehicle-icon ${isPlayerOwned ? 'player-owned' : 'npc-owned'} ${hasAlert ? 'alert' : ''}">
                                    <i class="fa-solid ${isPlayerOwned ? 'fa-id-card' : 'fa-car'}"></i>
                                </span>

                                <span class="vehicle-summary-main">
                                    <strong>${text(plate)}</strong>
                                    <small>${text(displayVehicle)}</small>
                                </span>

                                <span class="profile-badge ${isPlayerOwned ? 'player' : 'npc'}">
                                    ${isPlayerOwned ? 'Player Owned' : 'NPC'}
                                </span>

                                <span class="profile-expand-icon">
                                    <i class="fa-solid fa-chevron-down"></i>
                                </span>
                            </summary>

                            <div class="info-grid">
                                ${gridItem('<i class="fa-solid fa-car"></i>', 'Vehicle', displayVehicle)}
                                ${gridItem('<i class="fa-solid fa-hashtag"></i>', 'Plate', plate)}
                                ${gridItem('<i class="fa-solid fa-user"></i>', 'Owner', owner)}
                                ${gridItem('<i class="fa-solid fa-id-badge"></i>', 'Citizen ID', citizenDisplay)}
                                ${make && make !== 'Unknown' && make !== 'N/A' ? gridItem('<i class="fa-solid fa-industry"></i>', 'Make', make) : ''}
                                ${gridItem('<i class="fa-solid fa-wrench"></i>', 'Model', model || 'N/A')}
                                ${color && color !== 'Unknown' && color !== 'N/A' ? gridItem('<i class="fa-solid fa-palette"></i>', 'Color', color) : ''}
                                ${gridItem('<i class="fa-solid fa-circle-info"></i>', 'Source', isPlayerOwned ? 'Player Owned Vehicle' : 'NPC Vehicle Record')}
                            </div>

                            <details>
                                <summary>
                                    <i class="fa-solid fa-triangle-exclamation"></i>
                                    Flags / Markers
                                </summary>

                                <div class="icon-grid">
                                    ${vehicleFlagTiles({
                                        insurance,
                                        stolen,
                                        bolo,
                                        flagged,
                                        wanted,
                                        hasAlert
                                    })}
                                </div>
                            </details>
                        </details>
                    </div>
                `;
            }).join('')}
        </div>
    `;
}

function renderReports() {
    if (activeReportMode === 'create') {
        renderCreateReport();
        return;
    }

    if (activeReportMode === 'details' && activeReportDetails) {
        renderReportDetails();
        return;
    }

    content.innerHTML = `
        <div class="card">
            <h2><i class="fa-solid fa-file-lines"></i> Reports</h2>

            <button id="refreshReportsBtn" class="mini-action-btn">
                <i class="fa-solid fa-rotate"></i> Refresh Reports
            </button>

            <button id="createReportBtn" class="save-report-btn">
                <i class="fa-solid fa-plus"></i> Create New Report
            </button>

            <div class="report-list">
                ${
                    reportsList.length
                        ? reportsList.map(r => `
                            <details class="report-entry">
                                <summary>
                                    <i class="fa-solid fa-folder-open"></i>
                                    #${r.id} - ${text(r.title)}
                                </summary>

                                ${row('Type', r.report_type)}
                                ${row('Created By', r.created_by)}
                                ${row('Created At', formatDateTime(r.created_at))}

                                <button class="mini-action-btn report-open-btn" data-id="${r.id}">
                                    <i class="fa-solid fa-eye"></i> Open Full Report
                                </button>
                            </details>
                        `).join('')
                        : `<div class="card"><h2>No Reports Found</h2></div>`
                }
            </div>
        </div>
    `;

    document.getElementById('refreshReportsBtn').addEventListener('click', () => {
        nuiCallback('getReports');
    });

    document.getElementById('createReportBtn').addEventListener('click', () => {
        activeReportMode = 'create';

        reportDraft = {
            type: 'Incident',
            title: '',
            narrative: '',
            officers: [],
            peds: [],
            charges: [],
            photos: []
        };

        nuiCallback('getPersonnelDatabase');

        renderReports();
    });

    document.querySelectorAll('.report-open-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            nuiCallback('getReportDetails', {
                reportId: Number(btn.dataset.id)
            });
        });
    });
}

function saveDraftInputs() {
    const type = document.getElementById('reportType');
    const title = document.getElementById('reportTitle');
    const narrative = document.getElementById('reportNarrative');

    if (type) reportDraft.type = type.value;
    if (title) reportDraft.title = title.value;
    if (narrative) reportDraft.narrative = narrative.value;
}

function updateReportSummary() {
    const box = document.getElementById('reportSummary');
    if (!box) return;

    box.innerHTML = `
        ${row('Officers', reportDraft.officers.length)}
        ${row('Peds', reportDraft.peds.length)}
        ${row('Charges', reportDraft.charges.length)}
        ${row('Photos', reportDraft.photos.length)}

        <details>
            <summary>Attached Officers</summary>
            ${reportDraft.officers.map(o => row('Officer', o.name)).join('') || row('None', 'N/A')}
        </details>

        <details>
            <summary>Attached Peds</summary>
            ${reportDraft.peds.map(p => row('Ped', `${text(p.FirstName)} ${text(p.LastName)}`)).join('') || row('None', 'N/A')}
        </details>

        <details>
            <summary>Added Charges</summary>
            ${reportDraft.charges.map(c => row(
                `${c.name} x${c.count}`,
                `${c.ped_name || 'Unassigned'} | $${c.fine} / ${c.jail_time} months`
            )).join('') || row('None', 'N/A')}
        </details>
    `;
}

function startEditReport(details) {
    const r = details.report;

    editingReportId = r.id;

    reportDraft = {
        type: r.report_type || 'Incident',
        title: r.title || '',
        narrative: r.narrative || '',
        officers: (details.officers || []).map(o => ({
            name: o.officer_name,
            callsign: o.callsign,
            job: o.job
        })),
        peds: (details.peds || []).map(p => {
            try {
                return JSON.parse(p.ped_data || '{}');
            } catch (e) {
                return {
                    FirstName: p.firstname,
                    LastName: p.lastname,
                    DOB: p.dob,
                    ped_identifier: p.ped_identifier
                };
            }
        }),
        charges: (details.charges || []).map(c => ({
            code: c.code || '',
            name: c.charge_name || c.name || 'Charge',
            label: c.charge_name || c.name || 'Charge',
            category: c.category || '',
            fine: Number(c.fine || 0),
            jail_time: Number(c.jail_time || 0),
            count: Number(c.count || 1),
            ped_identifier: c.ped_identifier || '',
            ped_name: c.ped_name || 'Unassigned'
        })),
        photos: (details.photos || []).map(photo => ({
            url: photo.url,
            caption: photo.caption || '',
            position_x: Number(photo.position_x || 50),
            position_y: Number(photo.position_y || 50),
            zoom: Number(photo.zoom || 100)
        }))
    };

    activeReportMode = 'create';
    playSound('click');
    renderReports();
}

function renderReportDetails() {
    const d = activeReportDetails;
    const r = d.report;

    content.innerHTML = `
        <div class="card">
            <button class="mini-action-btn" id="backToReportsBtn">
                <i class="fa-solid fa-arrow-left"></i> Back to Reports
            </button>

            <button class="mini-action-btn" id="editReportBtn">
                <i class="fa-solid fa-pen-to-square"></i> Edit Report
            </button>

            <h2><i class="fa-solid fa-file-lines"></i> #${r.id} - ${text(r.title)}</h2>

            ${row('Type', r.report_type)}
            ${row('Created By', r.created_by)}
            ${row('Created At', formatDateTime(r.created_at))}
            ${r.updated_at ? row('Updated By', r.updated_by || 'N/A') : ''}
            ${r.updated_at ? row('Updated At', formatDateTime(r.updated_at)) : ''}

            <details open>
                <summary><i class="fa-solid fa-align-left"></i> Narrative</summary>
                <p class="report-narrative">${text(r.narrative)}</p>
            </details>

            <details>
                <summary><i class="fa-solid fa-user-shield"></i> Officers</summary>
                ${(d.officers || []).map(o => row(
                    o.officer_name,
                    `${text(o.callsign)} / ${text(o.job)}`
                )).join('') || row('None', 'N/A')}
            </details>

            <details>
                <summary><i class="fa-solid fa-users"></i> Profiles</summary>
                ${(d.peds || []).map(p => `
                    <button class="mini-action-btn open-report-ped-btn" data-ped='${encodeURIComponent(p.ped_data || '{}')}'>
                        <i class="fa-solid fa-user"></i>
                        ${text(p.firstname)} ${text(p.lastname)} - ${text(p.dob)}
                    </button>
                `).join('') || row('None', 'N/A')}
            </details>

            <details>
                <summary><i class="fa-solid fa-images"></i> Photos / Evidence</summary>
                ${
                    (d.photos || []).length
                        ? `<div class="photo-grid">
                            ${d.photos.map(photo => `
                                <div class="photo-card report-photo-viewer"
                                     data-url="${photo.url}"
                                     data-caption="${text(photo.caption || 'Evidence Photo')}">
                                    <img
                                        src="${photo.url}"
                                        style="
                                            object-position: ${photo.position_x || 50}% ${photo.position_y || 50}%;
                                            transform: scale(${(photo.zoom || 100) / 100});
                                        "
                                    />
                                    <small>${text(photo.caption || 'Evidence Photo')}</small>
                                    <small><i class="fa-solid fa-magnifying-glass"></i> Click to enlarge</small>
                                </div>
                            `).join('')}
                        </div>`
                        : row('Photos', 'None')
                }
            </details>

            <details>
                <summary><i class="fa-solid fa-gavel"></i> Charges</summary>
                ${(d.charges || []).map(c => row(
                    `${text(c.charge_name)} x${text(c.count)}`,
                    `${text(c.ped_name || 'Unassigned')} | $${text(c.fine)} / ${text(c.jail_time)} months`
                )).join('') || row('None', 'N/A')}
            </details>
        </div>
    `;

    document.getElementById('backToReportsBtn').addEventListener('click', () => {
        activeReportMode = 'list';
        activeReportDetails = null;
        renderReports();
    });

    document.getElementById('editReportBtn').addEventListener('click', () => {
        startEditReport(activeReportDetails);
    });

    document.querySelectorAll('.open-report-ped-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const ped = JSON.parse(decodeURIComponent(btn.dataset.ped || '{}'));
            activeTab = 'peds';
            renderSinglePedProfile(ped);
        });
    });

    document.querySelectorAll('.report-photo-viewer').forEach((card) => {
        card.addEventListener('click', () => {
            openPhotoViewer(card.dataset.url, card.dataset.caption);
        });
    });
}

function renderSinglePedProfile(p) {
    const flags = p.FlagsOrMarkers || {};
    const profilePic = p.ProfilePicture && p.ProfilePicture !== 'N/A' ? p.ProfilePicture : '';
    const pedIdentifier = getPedIdentifierJs(p);

    const profilePosX = p.ProfilePicturePositionX || 50;
    const profilePosY = p.ProfilePicturePositionY || 5;
    const profileZoom = p.ProfilePictureZoom || 100;

    nuiCallback('getPedPreviousReports', { ped_identifier: pedIdentifier });

    content.innerHTML = `
        <div class="card ped-card">
            <button class="mini-action-btn" onclick="renderPeds()">
                <i class="fa-solid fa-arrow-left"></i> Back to Profiles
            </button>

            <h2 class="card-title-line">
                <span class="status-light ${(flags.wanted_person || flags.active_warrant || p.Wanted_Person) ? 'alert' : 'clear'}"></span>
                <i class="fa-solid ${p.profileType === 'Player' ? 'fa-id-card' : 'fa-user'}"></i>
                ${text(p.FirstName)} ${text(p.LastName)}

                <span class="profile-badge ${p.profileType === 'Player' ? 'player' : 'npc'}">
                    ${p.profileType || 'NPC'}
                </span>
            </h2>

            <div class="profile-photo-wrap">
                <div class="profile-photo-frame">
                    ${
                        profilePic
                            ? `<img
                                class="profile-img-large"
                                src="${profilePic}"
                                style="
                                    object-position: ${profilePosX}% ${profilePosY}%;
                                    transform: scale(${profileZoom / 100});
                                "
                            />`
                            : `<div class="no-profile-img">No Image</div>`
                    }
                </div>
            </div>

            <div class="info-grid">
                ${gridItem('<i class="fa-solid fa-user"></i>', 'Name', `${text(p.FirstName)} ${text(p.LastName)}`)}
                ${gridItem('<i class="fa-solid fa-calendar"></i>', 'DOB', p.DOB)}
                ${gridItem('<i class="fa-solid fa-venus-mars"></i>', 'Gender', p.Gender)}
                ${gridItem('<i class="fa-solid fa-flag"></i>', 'Nationality', p.Nationality)}
                ${gridItem('<i class="fa-solid fa-phone"></i>', 'Phone', p.PhoneNumber)}
                ${gridItem('<i class="fa-solid fa-house"></i>', 'Address', p.Address, true)}
                ${gridItem('<i class="fa-solid fa-city"></i>', 'City / State', `${text(p.City)}, ${text(p.State)} ${text(p.PostalCode)}`)}
                ${gridItem('<i class="fa-solid fa-id-badge"></i>', 'Citizen ID', p.citizenid || p.ped_identifier || 'N/A')}
                ${gridItem('<i class="fa-solid fa-user-tag"></i>', 'Profile Type', p.profileType || 'NPC')}
            </div>

            <details>
                <summary><i class="fa-solid fa-id-badge"></i> Licenses</summary>
                <div class="icon-grid">
                    ${iconTile('fa-car', 'Car', p.License_Car)}
                    ${iconTile('fa-motorcycle', 'Motorcycle', p.License_Bike || p.License_Bike_Is_Valid)}
                    ${iconTile('fa-plane', 'Pilot', p.License_Pilot)}
                    ${iconTile('fa-truck', 'CDL', p.License_Truck)}
                    ${iconTile('fa-ship', 'Boat', p.License_Boat || p.License_Boat_Is_Valid)}
                </div>
            </details>

            <details>
                <summary><i class="fa-solid fa-triangle-exclamation"></i> Flags / Markers</summary>
                <div class="icon-grid">
                    ${activeFlagTiles(flags, p)}
                </div>
            </details>

            <details open>
                <summary><i class="fa-solid fa-folder-open"></i> Previous Reports</summary>
                <div id="pedPreviousReportsBox">
                    ${
                        pedReportsCache[pedIdentifier]
                            ? renderPedPreviousReportsHtml(pedReportsCache[pedIdentifier])
                            : row('Loading', '...')
                    }
                </div>
            </details>
        </div>
    `;
}

function renderPedPreviousReportsHtml(reports) {
    if (!reports || !reports.length) {
        return row('Previous Reports', 'None');
    }

    return reports.map(r => `
        <button class="mini-action-btn report-open-btn-inline" data-id="${r.id}">
            <i class="fa-solid fa-file-lines"></i>
            #${r.id} ${text(r.title)}
        </button>
    `).join('');
}

function renderReportPhotoPreviewList() {
    const box = document.getElementById('reportPhotoPreviewList');
    if (!box) return;

    if (!reportDraft.photos.length) {
        box.innerHTML = `<div class="grid-item full">No photos attached</div>`;
        return;
    }

    box.innerHTML = reportDraft.photos.map((photo, index) => `
        <div class="photo-card editable-photo-card">
            <div class="photo-position-frame" data-index="${index}">
                <img
                    src="${photo.url}"
                    style="
                        object-position: ${photo.position_x || 50}% ${photo.position_y || 50}%;
                        transform: scale(${(photo.zoom || 100) / 100});
                    "
                    draggable="false"
                />

                <button class="photo-remove-btn remove-report-photo-btn" data-index="${index}" title="Remove Photo">
                    <i class="fa-solid fa-trash"></i>
                </button>
            </div>

            <small>${text(photo.caption || 'Evidence Photo')}</small>

            <div class="photo-zoom-row">
                <i class="fa-solid fa-magnifying-glass-minus"></i>

                <input 
                    type="range" 
                    class="photo-zoom-slider" 
                    min="100" 
                    max="250" 
                    step="5" 
                    value="${photo.zoom || 100}" 
                    data-index="${index}"
                />

                <i class="fa-solid fa-magnifying-glass-plus"></i>
            </div>

            <small class="photo-position-hint">
                <i class="fa-solid fa-arrows-up-down-left-right"></i>
                Drag image to adjust
            </small>
        </div>
    `).join('');

    document.querySelectorAll('.remove-report-photo-btn').forEach((btn) => {
        btn.addEventListener('click', (e) => {
            e.stopPropagation();
            reportDraft.photos.splice(Number(btn.dataset.index), 1);
            playSound('click');
            renderReportPhotoPreviewList();
            updateReportSummary();
        });
    });

    document.querySelectorAll('.photo-zoom-slider').forEach((slider) => {
        slider.addEventListener('input', () => {
            const index = Number(slider.dataset.index);
            const zoom = Number(slider.value);

            reportDraft.photos[index].zoom = zoom;

            const frame = document.querySelector(`.photo-position-frame[data-index="${index}"]`);
            const img = frame ? frame.querySelector('img') : null;

            if (img) {
                img.style.transform = `scale(${zoom / 100})`;
            }
        });
    });

    enablePhotoDragPositioning();
}

function enablePhotoDragPositioning() {
    document.querySelectorAll('.photo-position-frame').forEach((frame) => {
        const img = frame.querySelector('img');
        const index = Number(frame.dataset.index);

        let dragging = false;

        const updatePosition = (clientX, clientY) => {
            const rect = frame.getBoundingClientRect();

            let x = ((clientX - rect.left) / rect.width) * 100;
            let y = ((clientY - rect.top) / rect.height) * 100;

            x = Math.max(0, Math.min(100, x));
            y = Math.max(0, Math.min(100, y));

            reportDraft.photos[index].position_x = Math.round(x);
            reportDraft.photos[index].position_y = Math.round(y);

            img.style.objectPosition = `${reportDraft.photos[index].position_x}% ${reportDraft.photos[index].position_y}%`;
        };

        frame.addEventListener('mousedown', (e) => {
            dragging = true;
            updatePosition(e.clientX, e.clientY);
        });

        window.addEventListener('mousemove', (e) => {
            if (!dragging) return;
            updatePosition(e.clientX, e.clientY);
        });

        window.addEventListener('mouseup', () => {
            dragging = false;
        });

        frame.addEventListener('wheel', (e) => {
            e.preventDefault();

            const currentZoom = Number(reportDraft.photos[index].zoom || 100);
            const nextZoom = e.deltaY < 0
                ? Math.min(currentZoom + 5, 250)
                : Math.max(currentZoom - 5, 100);

            reportDraft.photos[index].zoom = nextZoom;

            img.style.transform = `scale(${nextZoom / 100})`;

            const slider = document.querySelector(`.photo-zoom-slider[data-index="${index}"]`);
            if (slider) slider.value = nextZoom;
        });

        frame.addEventListener('touchstart', (e) => {
            dragging = true;
            const touch = e.touches[0];
            updatePosition(touch.clientX, touch.clientY);
        }, { passive: true });

        frame.addEventListener('touchmove', (e) => {
            if (!dragging) return;
            const touch = e.touches[0];
            updatePosition(touch.clientX, touch.clientY);
        }, { passive: true });

        frame.addEventListener('touchend', () => {
            dragging = false;
        });
    });
}

function getAvailableReportOfficers() {
    const officers =
        personnelDatabase ||
        database.personnel ||
        database.ERSPlayers ||
        [];

    return (officers || []).map((o) => {
        return {
            citizenid: o.citizenid || '',
            name: `${o.firstname || o.firstName || 'Unknown'} ${o.lastname || o.lastName || ''}`.trim(),
            callsign: o.callsign || 'N/A',
            job: o.last_service || o.job || o.service || 'N/A',
            is_on_duty: o.is_on_duty === true || o.is_on_duty === 1
        };
    });
}

function renderReportProfileList(peds, searchValue = '') {
    const list = document.getElementById('reportProfileList');
    if (!list) return;

    const search = searchValue.toLowerCase().trim();

    const filtered = (peds || []).filter((p) => {
        const fullName = `${p.FirstName || ''} ${p.LastName || ''}`.toLowerCase();
        const dob = String(p.DOB || '').toLowerCase();
        const citizenid = String(p.citizenid || '').toLowerCase();
        const pedIdentifier = String(p.ped_identifier || '').toLowerCase();
        const profileType = String(p.profileType || '').toLowerCase();

        return (
            !search ||
            fullName.includes(search) ||
            dob.includes(search) ||
            citizenid.includes(search) ||
            pedIdentifier.includes(search) ||
            profileType.includes(search)
        );
    });

    if (!filtered.length) {
        list.innerHTML = `<div class="grid-item full">No matching profiles found</div>`;
        return;
    }

    list.innerHTML = filtered.map((p) => {
        const selected = isPedSelected(p);
        const profileType = p.profileType || 'NPC';
        const identifier = p.citizenid || p.ped_identifier || 'N/A';

        return `
            <button
                class="report-profile-row ${selected ? 'selected' : ''}"
                data-ped="${encodeURIComponent(JSON.stringify(p))}"
            >
                <div class="report-profile-row-icon ${profileType === 'Player' ? 'player' : 'npc'}">
                    <i class="fa-solid ${profileType === 'Player' ? 'fa-id-card' : 'fa-user'}"></i>
                </div>

                <div class="report-profile-row-main">
                    <strong>${text(p.FirstName)} ${text(p.LastName)}</strong>
                    <span>${text(p.DOB || 'N/A')} / ${text(identifier)}</span>
                </div>

                <div class="report-profile-row-type ${profileType === 'Player' ? 'player' : 'npc'}">
                    ${text(profileType)}
                </div>

                <div class="report-profile-row-check">
                    <i class="fa-solid ${selected ? 'fa-circle-check' : 'fa-plus'}"></i>
                </div>
            </button>
        `;
    }).join('');

    document.querySelectorAll('.report-profile-row').forEach((btn) => {
        btn.addEventListener('click', () => {
            const ped = JSON.parse(decodeURIComponent(btn.dataset.ped || '{}'));

            saveDraftInputs();
            togglePed(ped);

            const input = document.getElementById('reportProfileSearch');
            renderReportProfileList(peds, input ? input.value : '');
        });
    });
}

function renderCreateReport() {
    if (!personnelDatabase || !personnelDatabase.length) {
        nuiCallback('getPersonnelDatabase');
    }
    const peds = database.peds || [];

    const personnelSource =
        personnelDatabase ||
        database.personnel ||
        database.ERSPlayers ||
        [];

    const personnel = Array.isArray(personnelSource)
        ? personnelSource.map((data, index) => ({
            id: data.citizenid || data.id || String(index),
            citizenid: data.citizenid || '',
            name: data.name || `${data.firstname || data.firstName || 'Unknown'} ${data.lastname || data.lastName || ''}`.trim(),
            callsign: data.callsign || 'N/A',
            job: data.job || data.last_service || data.service || 'N/A',
            is_on_duty: data.is_on_duty === true || data.is_on_duty === 1
        }))
        : Object.entries(personnelSource || {}).map(([id, data]) => ({
            id,
            citizenid: data.citizenid || id,
            name: data.name || `${data.firstname || data.firstName || 'Unknown'} ${data.lastname || data.lastName || ''}`.trim(),
            callsign: data.callsign || 'N/A',
            job: data.job || data.last_service || data.service || 'N/A',
            is_on_duty: data.is_on_duty === true || data.is_on_duty === 1
        }));

    content.innerHTML = `
        <div class="card">
            <button class="mini-action-btn" id="backToReportsListBtn">
                <i class="fa-solid fa-arrow-left"></i> Back to Reports
            </button>

            <h2>
                <i class="fa-solid fa-file-lines"></i>
                ${editingReportId ? `Edit Report #${editingReportId}` : 'Create Report'}
            </h2>

            <div class="report-form">
                <label>Report Type</label>
                <select id="reportType">
                    <option>Incident</option>
                    <option>Arrest</option>
                    <option>Citation</option>
                    <option>Traffic Stop</option>
                    <option>Use of Force</option>
                    <option>Callout Report</option>
                </select>

                <label>Title</label>
                <input id="reportTitle" placeholder="Report title..." value="${text(reportDraft.title || '')}" />

                <label>Narrative</label>
                <textarea id="reportNarrative" placeholder="Write report narrative...">${text(reportDraft.narrative || '')}</textarea>
            </div>

            <details open>
                <summary><i class="fa-solid fa-user-shield"></i> Toggle Officers</summary>
                <div class="mini-grid">
                    ${
                        personnel.length
                            ? personnel.map((o, index) => `
                                <button class="mini-tile officer-add ${isOfficerSelected(o) ? 'selected' : ''}" data-index="${index}">
                                    <i class="fa-solid fa-user-shield"></i>
                                    <span>${text(o.callsign)} - ${text(o.name)}</span>
                                    <small>${isOfficerSelected(o) ? 'Selected' : `${text(o.job)} ${o.is_on_duty ? '/ On Duty' : '/ Off Duty'}`}</small>
                                </button>
                            `).join('')
                            : '<p>No officers found.</p>'
                    }
                </div>
            </details>

            <details>
                <summary><i class="fa-solid fa-user"></i> Toggle Profile</summary>

                <div class="report-profile-search-row">
                    <input id="reportProfileSearch" placeholder="Search profiles by name, DOB, ID..." />
                </div>

                <div id="reportProfileList" class="report-profile-list"></div>
            </details>

            <details open>
                <summary><i class="fa-solid fa-gavel"></i> Charges Linked to Peds</summary>

                <div class="charge-search-row">
                    <input id="chargeSearch" placeholder="Search charges..." />
                    <button id="chargeSearchBtn">Search</button>
                </div>

                <div id="chargeResults" class="mini-grid"></div>

                <div class="card">
                    <h2>Selected Peds For Charges</h2>
                    ${
                        reportDraft.peds.length
                            ? reportDraft.peds.map(p => {
                                const pedId = getPedIdentifierJs(p);

                                return `
                                    <div class="charge-ped-block">
                                        <div class="charge-ped-header">
                                            <h2>${text(p.FirstName)} ${text(p.LastName)}</h2>

                                            <button class="remove-report-ped-btn" data-ped="${text(pedId)}" title="Remove Profile">
                                                <i class="fa-solid fa-xmark"></i>
                                            </button>
                                        </div>

                                        <div class="mini-grid ped-charge-targets" data-ped="${text(pedId)}"></div>
                                    </div>
                                `;
                            }).join('')
                            : row('Select Peds', 'Add peds before adding charges')
                    }
                </div>
            </details>

            <details open>
                <summary><i class="fa-solid fa-images"></i> Photos / Evidence</summary>

                <div class="report-form">
                    <label>Image URL</label>
                    <input id="reportPhotoUrl" placeholder="Paste Image URL..." />

                    <label>Caption</label>
                    <input id="reportPhotoCaption" placeholder="Optional caption..." />

                    <button id="addReportPhotoBtn" class="save-report-btn">
                        <i class="fa-solid fa-plus"></i> Attach Photo
                    </button>
                </div>

                <div id="reportPhotoPreviewList" class="photo-grid"></div>
            </details>

            <div class="card">
                <h2>Report Summary</h2>
                <div id="reportSummary"></div>

                <button id="saveReportBtn" class="save-report-btn">
                    <i class="fa-solid fa-floppy-disk"></i>
                    ${editingReportId ? 'Update Report' : 'Save Report'}
                </button>
            </div>
        </div>
    `;

    const reportType = document.getElementById('reportType');
    if (reportType && reportDraft.type) {
        reportType.value = reportDraft.type;
    }

    document.getElementById('backToReportsListBtn').addEventListener('click', () => {
        activeReportMode = 'list';
        nuiCallback('getReports');
    });

    document.querySelectorAll('.officer-add').forEach(btn => {
        btn.addEventListener('click', () => {
            saveDraftInputs();
            toggleOfficer(personnel[Number(btn.dataset.index)]);
        });
    });

    renderReportProfileList(peds);

    const reportProfileSearch = document.getElementById('reportProfileSearch');

    if (reportProfileSearch) {
        reportProfileSearch.addEventListener('input', () => {
            renderReportProfileList(peds, reportProfileSearch.value);
        });
    }

    document.getElementById('chargeSearchBtn').addEventListener('click', () => {
        const search = document.getElementById('chargeSearch').value;
        nuiCallback('searchCharges', { search });
    });

    document.querySelectorAll('.remove-report-ped-btn').forEach((btn) => {
        btn.addEventListener('click', () => {
            const pedId = btn.dataset.ped;

            saveDraftInputs();

            reportDraft.peds = (reportDraft.peds || []).filter((p) => {
                return getPedIdentifierJs(p) !== pedId;
            });

            reportDraft.charges = (reportDraft.charges || []).filter((c) => {
                return c.ped_identifier !== pedId;
            });

            playSound('click');
            renderCreateReport();
        });
    });

    document.getElementById('saveReportBtn').addEventListener('click', () => {
        saveDraftInputs();

        if (editingReportId) {
            nuiCallback('updateReport', {
                reportId: editingReportId,
                report: reportDraft
            });
        } else {
            nuiCallback('saveReport', reportDraft);
        }

        editingReportId = null;
        activeReportMode = 'list';
        activeReportDetails = null;
        reportsLoaded = false;

        setTimeout(() => {
            nuiCallback('getReports');
        }, 500);
    });

    document.getElementById('addReportPhotoBtn').addEventListener('click', () => {
        const url = document.getElementById('reportPhotoUrl').value.trim();
        const caption = document.getElementById('reportPhotoCaption').value.trim();

        if (!url) return;

        reportDraft.photos.push({
            url,
            caption,
            position_x: 50,
            position_y: 50,
            zoom: 100
        });

        document.getElementById('reportPhotoUrl').value = '';
        document.getElementById('reportPhotoCaption').value = '';

        playSound('click');
        renderReportPhotoPreviewList();
        updateReportSummary();
    });

    renderReportPhotoPreviewList();
    updateReportSummary();
    renderChargeResults(chargeResults);
}



function renderChargeResults(charges) {
    const box = document.getElementById('chargeResults');
    if (!box) return;

    if (!charges || !charges.length) {
        box.innerHTML = row('Charges', 'Search to add charges');
        return;
    }

    box.innerHTML = charges.map((c, index) => `
        <div class="mini-tile">
            <i class="fa-solid fa-gavel"></i>
            <span>${text(c.name)}</span>
            <small>$${text(c.fine)} / ${text(c.jail_time)} months</small>

            ${
                reportDraft.peds.length
                    ? reportDraft.peds.map((p, pIndex) => `
                        <button class="mini-action-btn charge-to-ped-btn" data-charge="${index}" data-ped="${pIndex}">
                            Add to ${text(p.FirstName)}
                        </button>
                    `).join('')
                    : `<small>Select ped first</small>`
            }
        </div>
    `).join('');

    document.querySelectorAll('.charge-to-ped-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const charge = charges[Number(btn.dataset.charge)];
            const ped = reportDraft.peds[Number(btn.dataset.ped)];

            addChargeToPed(charge, ped);
            playSound('click');
        });
    });
}

function gridItem(icon, label, value, full = false) {
    return `
        <div class="grid-item ${full ? 'full' : ''}">
            <div class="grid-label">${icon} ${label}</div>
            <div class="grid-value">${text(value)}</div>
        </div>
    `;
}

function iconTile(icon, label, value) {
    return `
        <div class="icon-tile">
            <i class="fa-solid ${icon}"></i>
            <span>${label}</span>
            <small>${text(value)}</small>
        </div>
    `;
}

function flagTile(icon, label, value) {
    const active = value === true || value === 'true';

    return `
        <div class="icon-tile ${active ? 'alert' : 'clear'}">
            <i class="fa-solid ${icon}"></i>
            <span>${label}</span>
        </div>
    `;
}

function activeFlagTiles(flags, p) {
    const flagList = [
        { icon: 'fa-user-slash', label: 'Wanted', value: flags.wanted_person || p.Wanted_Person },
        { icon: 'fa-gavel', label: 'Warrant', value: flags.active_warrant },
        { icon: 'fa-gun', label: 'Dangerous', value: flags.armed_and_dangerous },
        { icon: 'fa-car-burst', label: 'Traffic', value: flags.traffic_violation },
        { icon: 'fa-pills', label: 'Drugs', value: flags.drug_related },
        { icon: 'fa-users', label: 'Gang', value: flags.gang_affiliation },
        { icon: 'fa-mask', label: 'Theft', value: flags.theft },
        { icon: 'fa-house-lock', label: 'Burglary', value: flags.burglary },
        { icon: 'fa-hand-fist', label: 'Assault', value: flags.assault },
        { icon: 'fa-skull', label: 'Homicide', value: flags.homicide },
        { icon: 'fa-bomb', label: 'Terrorism', value: flags.terrorism },
        { icon: 'fa-brain', label: 'Mental Health', value: flags.mental_health_issues },
        { icon: 'fa-circle-exclamation', label: 'Other', value: flags.other }
    ];

    const active = flagList.filter(f => f.value === true || f.value === 'true');

    if (!active.length) {
        return `
            <div class="icon-tile clear">
                <i class="fa-solid fa-circle-check"></i>
                <span>No Active Flags</span>
            </div>
        `;
    }

    return active.map(f => flagTile(f.icon, f.label, true)).join('');
}

function renderCallouts() {
    const callouts = (database.callouts || []).filter(matchesSearch);

    if (!callouts.length) {
        content.innerHTML = `<div class="card"><h2>No Callout Records</h2></div>`;
        return;
    }

    content.innerHTML = `<div class="grid">` + callouts.map((c) => {
        return `
            <div class="card">
                <h2>${text(c.callName)}</h2>
                ${row('Location', `${text(c.callPostal)} ${text(c.callStreet)}`)}
                ${row('Caller', `${text(c.callFirstName)} ${text(c.callLastName)}`)}

                <details>
                    <summary>View Call Details</summary>
                    ${row('Description', c.callDesc)}
                    ${row('Units Requested', c.callUnits)}
                    ${row('Postal', c.callPostal)}
                    ${row('Street', c.callStreet)}
                </details>
            </div>
        `;
    }).join('') + `</div>`;
}

function formatDutyTime(seconds) {
    seconds = Number(seconds || 0);

    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    const secs = seconds % 60;

    if (hours > 0) return `${hours}h ${minutes}m`;
    if (minutes > 0) return `${minutes}m ${secs}s`;

    return `${secs}s`;
}

function findProfileForPersonnel(person) {
    const fullName = `${person.firstname || ''} ${person.lastname || ''}`.toLowerCase().trim();

    return (database.peds || []).find((p) => {
        const pedName = `${p.FirstName || ''} ${p.LastName || ''}`.toLowerCase().trim();

        return (
            (person.citizenid && p.citizenid && person.citizenid === p.citizenid) ||
            (fullName && pedName && fullName === pedName)
        );
    }) || {};
}

function personnelStatusClass(status) {
    if (status === '10-7') return 'offline';
    if (status === '10-8') return 'available';
    if (status === '10-6' || status === 'Traffic' || status === 'Signal 11' || status === 'Signal 41' || status === 'Signal 42') return 'busy';

    return 'available';
}

function personnelStatusIcon(status) {
    if (status === '10-7') return 'fa-power-off';
    if (status === '10-8') return 'fa-check';
    if (status === '10-6') return 'fa-pause';
    if (status === 'Traffic') return 'fa-car';
    if (status === 'Signal 11') return 'fa-user-shield';
    if (status === 'Signal 41') return 'fa-user';
    if (status === 'Signal 42') return 'fa-handcuffs';

    return 'fa-circle';
}

function renderPersonnel() {
    const people = (personnelDatabase || []).filter(matchesSearch);

    if (!people.length) {
        content.innerHTML = `
            <div class="card">
                <h2><i class="fa-solid fa-users"></i> No Personnel Records</h2>

                <button class="mini-action-btn" onclick="nuiCallback('getPersonnelDatabase')">
                    <i class="fa-solid fa-rotate"></i> Refresh
                </button>
            </div>
        `;
        return;
    }

    content.innerHTML = `
        <div class="personnel-page">
            <div class="personnel-header">
                <h2><i class="fa-solid fa-id-card-clip"></i> ERS Personnel</h2>

                <button class="mini-action-btn" id="refreshPersonnelBtn">
                    <i class="fa-solid fa-rotate"></i> Refresh
                </button>
            </div>

            <div class="personnel-id-grid">
                ${people.map((p) => {
                    const profile = findProfileForPersonnel(p);

                    const profilePic = profile.ProfilePicture && profile.ProfilePicture !== 'N/A'
                        ? profile.ProfilePicture
                        : '';

                    const posX = profile.ProfilePicturePositionX || 50;
                    const posY = profile.ProfilePicturePositionY || 5;
                    const zoom = profile.ProfilePictureZoom || 100;

                    const totalAccepted = (p.services || []).reduce((sum, s) => sum + Number(s.accepted_callouts || 0), 0);
                    const totalArrived = (p.services || []).reduce((sum, s) => sum + Number(s.arrived_callouts || 0), 0);
                    const totalSeconds = (p.services || []).reduce((sum, s) => sum + Number(s.total_seconds || 0), 0);

                    const unitStatus = p.unit_status || '10-8';
                    const statusClass = personnelStatusClass(unitStatus);

                    return `
                        <div class="personnel-id-card">
                            <details class="personnel-details">
                                <summary class="personnel-id-summary">
                                    <div class="personnel-photo-frame">
                                        <span class="personnel-photo-status status-light ${p.is_on_duty ? 'clear' : 'offline'}"></span>

                                        ${
                                            profilePic
                                                ? `<img
                                                    src="${profilePic}"
                                                    style="
                                                        object-position: ${posX}% ${posY}%;
                                                        transform: scale(${zoom / 100});
                                                    "
                                                />`
                                                : `<div class="personnel-photo-placeholder">
                                                    <i class="fa-solid fa-user"></i>
                                                </div>`
                                        }
                                    </div>

                                    <div class="personnel-id-content">
                                        <div class="personnel-id-top">
                                            <div class="personnel-name-block">
                                                <div class="personnel-name">
                                                    ${text(p.firstname)} ${text(p.lastname)}
                                                </div>

                                                <div class="personnel-unit-line">
                                                    <span>
                                                        <i class="fa-solid fa-hashtag"></i>
                                                        ${text(p.callsign || 'N/A')}
                                                    </span>

                                                    <span>
                                                        <i class="fa-solid fa-briefcase"></i>
                                                        ${text(p.last_service || 'N/A')}
                                                    </span>
                                                </div>
                                            </div>

                                            <i class="fa-solid fa-chevron-down personnel-expand-icon"></i>
                                        </div>

                                        <div class="personnel-location-line">
                                            <i class="fa-solid fa-location-dot"></i>
                                            <span>${text(p.location || 'Unknown Location')}</span>
                                        </div>

                                        <div class="personnel-badge-row">
                                            <span class="personnel-duty-tag ${p.is_on_duty ? 'on' : 'off'}">
                                                <i class="fa-solid fa-user-clock"></i>
                                                ${p.is_on_duty ? 'ON DUTY' : 'OFF DUTY'}
                                            </span>

                                            <span class="unit-status-tag ${statusClass}">
                                                <i class="fa-solid ${personnelStatusIcon(unitStatus)}"></i>
                                                ${text(unitStatus)}
                                            </span>
                                        </div>
                                    </div>
                                </summary>

                                <div class="personnel-expanded">
                                    <div class="info-grid compact-grid">
                                        ${gridItem('<i class="fa-solid fa-clock"></i>', 'Total Duty', formatDutyTime(totalSeconds))}
                                        ${gridItem('<i class="fa-solid fa-bullhorn"></i>', 'Accepted Calls', totalAccepted)}
                                        ${gridItem('<i class="fa-solid fa-location-dot"></i>', 'Arrived Calls', totalArrived)}
                                        ${gridItem('<i class="fa-solid fa-signal"></i>', 'Unit Status', unitStatus)}
                                    </div>

                                    <div class="personnel-service-stats">
                                        ${(p.services || []).map((s) => `
                                            <div class="service-stat-card">
                                                <i class="fa-solid ${serviceIcon(s.service)}"></i>

                                                <div>
                                                    <strong>${text(s.service || 'Service')}</strong>
                                                    <span>${formatDutyTime(s.total_seconds)}</span>
                                                </div>

                                                <small>
                                                    ${text(s.accepted_callouts || 0)} accepted /
                                                    ${text(s.arrived_callouts || 0)} arrived
                                                </small>
                                            </div>
                                        `).join('') || `
                                            <div class="service-stat-card">
                                                <i class="fa-solid fa-circle-info"></i>
                                                <div>
                                                    <strong>No Stats</strong>
                                                    <span>N/A</span>
                                                </div>
                                                <small>No service records</small>
                                            </div>
                                        `}
                                    </div>
                                </div>
                            </details>
                        </div>
                    `;
                }).join('')}
            </div>
        </div>
    `;

    document.getElementById('refreshPersonnelBtn').addEventListener('click', () => {
        playSound('click');
        nuiCallback('getPersonnelDatabase');
    });
}

function serviceIcon(service) {
    if (service === 'police') return 'fa-handcuffs';
    if (service === 'ambulance') return 'fa-truck-medical';
    if (service === 'fire') return 'fa-fire';
    if (service === 'tow') return 'fa-truck-pickup';

    return 'fa-user-shield';
}

function unitStatusClass(status) {
    if (status === '10-7') return 'offline';
    if (status === '10-8') return 'available';
    if (status === '10-6' || status === 'Traffic' || status === 'Signal 11') return 'busy';
    return '';
}

function renderServices() {
    const requestServices = [
        { icon: 'ambulance', label: 'AMBULANCE', sublabel: 'Request EMS response', event: 'ersi:call:ambulance' },
        { icon: 'handcuffs', label: 'PD TRANSPORT', sublabel: 'Request police transport', event: 'ersi:call:police' },
        { icon: 'fire', label: 'FIRE RESCUE', sublabel: 'Request fire rescue', event: 'ersi:call:requestfire' },
        { icon: 'taxi', label: 'TAXI', sublabel: 'Request taxi service', event: 'ersi:call:taxi' },
        { icon: 'truck-pickup', label: 'TOW-TRUCK', sublabel: 'Request tow services', event: 'ersi:call:tow' },
        { icon: 'tools', label: 'MECHANIC', sublabel: 'Request mechanic assistance', event: 'ersi:call:mechanic' },
        { icon: 'skull-crossbones', label: 'CORONER', sublabel: 'Request coroner services', event: 'ersi:call:coroner' },
        { icon: 'paw', label: 'ANIMAL RESCUE', sublabel: 'Request animal rescue', event: 'ersi:call:animalrescue' },
        { icon: 'broom', label: 'ROAD SERVICE', sublabel: 'Request roadway cleanup', event: 'ersi:call:roadservice' }
    ];

    const cancelServices = [
        { icon: 'ambulance', label: 'CANCEL AMBULANCE', sublabel: 'Cancel EMS response', event: 'ersi:call:cancelambulance' },
        { icon: 'handcuffs', label: 'CANCEL POLICE', sublabel: 'Cancel police response', event: 'ersi:call:cancelpolice' },
        { icon: 'fire', label: 'CANCEL FIRE', sublabel: 'Cancel fire response', event: 'ersi:call:cancelfire' },
        { icon: 'taxi', label: 'CANCEL TAXI', sublabel: 'Cancel taxi request', event: 'ersi:call:canceltaxi' },
        { icon: 'truck-pickup', label: 'CANCEL TOW', sublabel: 'Cancel tow request', event: 'ersi:call:canceltow' },
        { icon: 'tools', label: 'CANCEL MECHANIC', sublabel: 'Cancel mechanic request', event: 'ersi:call:cancelmechanic' },
        { icon: 'skull-crossbones', label: 'CANCEL CORONER', sublabel: 'Cancel coroner request', event: 'ersi:call:cancelcoroner' },
        { icon: 'paw', label: 'CANCEL ANIMAL RESCUE', sublabel: 'Cancel animal rescue', event: 'ersi:call:cancelanimalrescue' },
        { icon: 'broom', label: 'CANCEL ROAD SERVICE', sublabel: 'Cancel road service', event: 'ersi:call:cancelroadservice' }
    ];

    const makeTile = (item, type = 'request') => `
        <button class="service-tile ${type}" data-event="${item.event}">
            <div class="service-tile-icon">
                <i class="fa-solid fa-${item.icon}"></i>
            </div>

            <div class="service-tile-text">
                <div class="service-tile-title">${text(item.label)}</div>
                <div class="service-tile-subtitle">${text(item.sublabel)}</div>
            </div>
        </button>
    `;

    content.innerHTML = `
        <div class="services-page">
            <div class="service-section">
                <div class="service-section-header">
                    <div class="service-section-title">
                        <i class="fa-solid fa-siren-on"></i>
                        Request Services
                    </div>
                    <div class="service-section-subtitle">
                        DISPATCH SUPPORT & FIELD RESOURCES
                    </div>
                </div>

                <div class="service-grid">
                    ${requestServices.map((item) => makeTile(item, 'request')).join('')}
                </div>
            </div>

            <div class="service-section">
                <div class="service-section-header">
                    <div class="service-section-title">
                        <i class="fa-solid fa-ban"></i>
                        Cancel Services
                    </div>
                    <div class="service-section-subtitle">
                        CANCEL ACTIVE SERVICE REQUESTS
                    </div>
                </div>

                <div class="service-grid">
                    ${cancelServices.map((item) => makeTile(item, 'cancel')).join('')}
                </div>
            </div>
        </div>
    `;

    document.querySelectorAll('.service-tile').forEach((btn) => {
        btn.addEventListener('click', () => {
            const eventName = btn.dataset.event;
            playSound('click');

            nuiCallback('triggerServiceEvent', {
                event: eventName
            });
        });
    });
}

function renderDispatch() {
    if (!dispatchAlerts.length) {
        content.innerHTML = `<div class="card"><h2>No Dispatch Alerts</h2></div>`;
        return;
    }

    content.innerHTML = `<div class="grid">` + dispatchAlerts.map((a) => {
        return `
            <div class="dispatch-card priority-${a.priority}">
                <div class="dispatch-header">
                    <span class="dispatch-code">${a.code || 'CALL'}</span>
                    <span class="dispatch-time">${a.time}</span>
                </div>

                <div class="dispatch-title">
                    ${a.title}
                </div>

                <div class="dispatch-message">
                    ${a.message}
                </div>

                <div class="dispatch-location">
                    <i class="fa-solid fa-location-dot"></i>
                    ${a.street}
                </div>
            </div>
        `;
    }).join('') + `</div>`;
}

function getPedIdentifierJs(p) {
    const first = String(p.FirstName || 'unknown').toLowerCase();
    const last = String(p.LastName || 'unknown').toLowerCase();
    const dob = p.DOB || 'nodob';

    return `${first}_${last}_${dob}`;
}

function isOfficerSelected(officer) {
    return reportDraft.officers.some(o => o.id === officer.id || o.name === officer.name);
}

function isPedSelected(ped) {
    const id = getPedIdentifierJs(ped);
    return reportDraft.peds.some(p => getPedIdentifierJs(p) === id);
}

function toggleOfficer(officer) {
    const index = reportDraft.officers.findIndex(o => o.id === officer.id || o.name === officer.name);

    if (index >= 0) {
        reportDraft.officers.splice(index, 1);
    } else {
        reportDraft.officers.push(officer);
    }

    renderReports();
}

function togglePed(ped) {
    const id = getPedIdentifierJs(ped);
    const index = reportDraft.peds.findIndex(p => getPedIdentifierJs(p) === id);

    if (index >= 0) {
        reportDraft.peds.splice(index, 1);

        reportDraft.charges = reportDraft.charges.filter(c => c.ped_identifier !== id);
    } else {
        ped.ped_identifier = id;
        reportDraft.peds.push(ped);
    }

    renderReports();
}

function addChargeToPed(charge, ped) {
    const pedIdentifier = getPedIdentifierJs(ped);
    const pedName = `${text(ped.FirstName)} ${text(ped.LastName)}`;

    const existing = reportDraft.charges.find(c =>
        c.name === charge.name && c.ped_identifier === pedIdentifier
    );

    if (existing) {
        existing.count += 1;
    } else {
        reportDraft.charges.push({
            name: charge.name,
            fine: charge.fine,
            jail_time: charge.jail_time,
            count: 1,
            ped_identifier: pedIdentifier,
            ped_name: pedName
        });
    }

    updateReportSummary();
}

function updateTabletStatus() {
    const timeBox = document.getElementById('tabletTime');
    const charBox = document.getElementById('tabletCharacter');
    const callsignBox = document.getElementById('tabletCallsign');

    if (timeBox) {
        const now = new Date();
        timeBox.textContent = now.toLocaleTimeString([], {
            hour: '2-digit',
            minute: '2-digit'
        });
    }

    if (charBox) {
        charBox.textContent = database.characterName || 'Unknown';
    }

    if (callsignBox) {
        callsignBox.textContent = `Callsign: ${database.callsign || 'N/A'}`;
    }
}

