document.addEventListener('DOMContentLoaded', function() {
    // UI Elements
    const mainContainer = document.getElementById('main-container');
    const closeBtn = document.getElementById('close-btn');
    
    // Robbery Type Selection
    const robberyTypeBtns = document.querySelectorAll('.robbery-type-btn');
    let currentRobberyType = 'store';
    
    // Minigame Selection
    const minigameCards = document.querySelectorAll('.minigame-card');
    const minigameSettings = document.getElementById('minigame-settings');
    let selectedMinigame = 'none';
    
    // Position
    const grabPositionBtn = document.getElementById('grab-position-btn');
    const posX = document.getElementById('pos-x');
    const posY = document.getElementById('pos-y');
    const posZ = document.getElementById('pos-z');
    const posHeading = document.getElementById('pos-heading');
    
    // Actions
    const saveRobberyBtn = document.getElementById('save-robbery-btn');
    const deleteRobberyBtn = document.getElementById('delete-robbery-btn');
    
    // Saved Robberies
    const savedRobberiesList = document.getElementById('saved-robberies');
    let selectedRobberyId = null;
    
    // Event Listeners
    closeBtn.addEventListener('click', closeMenu);
    
    // Robbery Type Selection
    robberyTypeBtns.forEach(btn => {
        btn.addEventListener('click', function() {
            currentRobberyType = this.dataset.type;
            robberyTypeBtns.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
        });
    });
    
    // Minigame Selection
    minigameCards.forEach(card => {
        card.addEventListener('click', function() {
            selectedMinigame = this.dataset.minigame;
            minigameCards.forEach(c => c.classList.remove('active'));
            this.classList.add('active');
            
            updateMinigameSettings();
        });
    });
    
    // Grab Position
    grabPositionBtn.addEventListener('click', function() {
        fetch(`https://${GetParentResourceName()}/getPlayerPosition`, {
            method: 'POST'
        }).then(resp => resp.json()).then(data => {
            if (data.position) {
                posX.value = data.position.x.toFixed(4);
                posY.value = data.position.y.toFixed(4);
                posZ.value = data.position.z.toFixed(4);
                posHeading.value = data.position.h.toFixed(4);
            }
        });
    });
    
    // Save Robbery
    saveRobberyBtn.addEventListener('click', function() {
        const robberyData = {
            name: document.getElementById('robbery-name').value,
            type: currentRobberyType,
            cooldown: parseInt(document.getElementById('robbery-cooldown').value),
            rewards: document.getElementById('robbery-rewards').value.split(',').map(item => item.trim()),
            required: document.getElementById('robbery-required').value.split(',').map(item => item.trim()),
            alert: document.getElementById('robbery-alert').value,
            position: {
                x: parseFloat(posX.value),
                y: parseFloat(posY.value),
                z: parseFloat(posZ.value),
                h: parseFloat(posHeading.value)
            },
            radius: parseFloat(document.getElementById('robbery-radius').value),
            minigame: {
                type: selectedMinigame,
                difficulty: document.getElementById('minigame-difficulty').value,
                attempts: parseInt(document.getElementById('minigame-attempts').value)
            },
            id: selectedRobberyId
        };
        
        fetch(`https://${GetParentResourceName()}/saveRobbery`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(robberyData)
        }).then(resp => resp.json()).then(data => {
            if (data.success) {
                loadSavedRobberies();
                resetForm();
            }
        });
    });
    
    // Delete Robbery
    deleteRobberyBtn.addEventListener('click', function() {
        if (!selectedRobberyId) return;
        
        fetch(`https://${GetParentResourceName()}/deleteRobbery`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ id: selectedRobberyId })
        }).then(resp => resp.json()).then(data => {
            if (data.success) {
                loadSavedRobberies();
                resetForm();
            }
        });
    });
    
    // Functions
    function updateMinigameSettings() {
        if (selectedMinigame === 'none') {
            minigameSettings.classList.remove('active');
        } else {
            minigameSettings.classList.add('active');
            document.getElementById('minigame-selected').textContent = 
                `Selected: ${selectedMinigame.charAt(0).toUpperCase() + selectedMinigame.slice(1)}`;
        }
    }
    
    function loadSavedRobberies() {
        fetch(`https://${GetParentResourceName()}/getSavedRobberies`, {
            method: 'POST'
        }).then(resp => resp.json()).then(data => {
            savedRobberiesList.innerHTML = '';
            
            if (data.robberies && data.robberies.length > 0) {
                data.robberies.forEach(robbery => {
                    const btn = document.createElement('button');
                    btn.className = 'robbery-item-btn';
                    btn.textContent = `${robbery.name} (${robbery.type})`;
                    btn.dataset.id = robbery.id;
                    
                    btn.addEventListener('click', function() {
                        selectedRobberyId = robbery.id;
                        document.querySelectorAll('.robbery-item-btn').forEach(b => b.classList.remove('selected'));
                        this.classList.add('selected');
                        loadRobberyData(robbery);
                    });
                    
                    savedRobberiesList.appendChild(btn);
                });
            } else {
                const msg = document.createElement('p');
                msg.className = 'no-robberies-msg';
                msg.textContent = 'No saved robberies';
                savedRobberiesList.appendChild(msg);
            }
        });
    }
    
    function loadRobberyData(robbery) {
        document.getElementById('robbery-name').value = robbery.name;
        document.getElementById('robbery-cooldown').value = robbery.cooldown;
        document.getElementById('robbery-rewards').value = robbery.rewards.join(', ');
        document.getElementById('robbery-required').value = robbery.required.join(', ');
        document.getElementById('robbery-alert').value = robbery.alert;
        
        posX.value = robbery.position.x;
        posY.value = robbery.position.y;
        posZ.value = robbery.position.z;
        posHeading.value = robbery.position.h;
        
        document.getElementById('robbery-radius').value = robbery.radius;
        
        selectedMinigame = robbery.minigame.type;
        minigameCards.forEach(card => {
            card.classList.remove('active');
            if (card.dataset.minigame === selectedMinigame) {
                card.classList.add('active');
            }
        });
        
        document.getElementById('minigame-difficulty').value = robbery.minigame.difficulty;
        document.getElementById('minigame-attempts').value = robbery.minigame.attempts;
        
        updateMinigameSettings();
    }
    
    function resetForm() {
        document.getElementById('robbery-name').value = '';
        document.getElementById('robbery-cooldown').value = '30';
        document.getElementById('robbery-rewards').value = '';
        document.getElementById('robbery-required').value = '';
        document.getElementById('robbery-alert').value = 'none';
        
        posX.value = '';
        posY.value = '';
        posZ.value = '';
        posHeading.value = '';
        
        document.getElementById('robbery-radius').value = '2.0';
        
        selectedMinigame = 'none';
        minigameCards.forEach(card => {
            card.classList.remove('active');
            if (card.dataset.minigame === 'none') {
                card.classList.add('active');
            }
        });
        
        document.getElementById('minigame-difficulty').value = 'medium';
        document.getElementById('minigame-attempts').value = '3';
        
        updateMinigameSettings();
        selectedRobberyId = null;
    }
    
    function closeMenu() {
        fetch(`https://${GetParentResourceName()}/closeMenu`, {
            method: 'POST'
        });
    }
    
    // Initialize
    loadSavedRobberies();
    resetForm();
    
    // Listen for NUI messages
    window.addEventListener('message', function(event) {
        const data = event.data;
        
        if (data.action === 'open') {
            mainContainer.style.display = 'block';
            document.body.style.overflow = 'hidden';
        } else if (data.action === 'close') {
            mainContainer.style.display = 'none';
            document.body.style.overflow = 'auto';
        }
    });
});
