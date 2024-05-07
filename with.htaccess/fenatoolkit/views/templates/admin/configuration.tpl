{*
* Copyright since 2023 Fena Labs Ltd
*
* NOTICE OF LICENSE
*
* This source file is subject to the Academic Free License (AFL 3.0)
* that is bundled with this package in the file LICENSE.txt.
* It is also available through the world-wide-web at this URL:
* http://opensource.org/licenses/afl-3.0.php
* If you did not receive a copy of the license and are unable to
* obtain it through the world-wide-web, please send an email
* to license@prestashop.com so we can send you a copy immediately.
*
* DISCLAIMER
*
* Do not edit or add to this file if you wish to upgrade PrestaShop to newer
* versions in the future. If you wish to customize PrestaShop for your
* needs please refer to http://www.prestashop.com for more information.
*
*  @author    "Fena <support@fena.co>"
*  @copyright Since 2023 Fena Labs Ltd
*  @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
*}

<form method="post">
    <div class="config-Top">
        <img src="" class="logo1">
        
    </div>
<div class="panel">
    <div class="panel-heading">
        {l s='Configuration' mod='fenatoolkit'}

    </div>
    <div class="panel-body">

          <h1>Please Enter Client ID and Secret</h1>

            <label for="print">{l s='Enter ClientId' mod='fenatoolkit'}</label>
            <input type="text"
                   name="clientId"
                   id="clientId"
                   class="form-control"
                   placeholder="8afa74ae-6ef9-48bb-93b2-9fe8be53db50"
                   value="{$FENA_CLIENTID}"/>

        <label for="print">{l s='Enter Your Client Secret' mod='fenatoolkit'}</label>
        <input type="text"
               name="clientSecret"
               id="clientSecret"
               class="form-control"
               placeholder="8afa74ae-6ef9-48bb-93b2-9fe8be53db50"
               value="{$FENA_CLIENTSECRET}"/>

    <!-- Add the dropdown with the name "Select Bank" -->
        <label for="selectBank">{l s='Select Bank' mod='fenatoolkit'}</label>
        <select name="selectBank" id="selectBank" class="form-control">
           <option value="">{l s='Select Bank' mod='fenatoolkit'}</option>
    <!-- Placeholder option for the initial state -->
    <!-- Add more options as needed -->
        </select>

    <!-- Add the button for making the API call -->
        <button type="button" id="fetchDataButton" class="btn btn-default" style="margin-top: 10px;">
           {l s='Validate' mod='fenatoolkit'}
        </button>
        <div style="margin-top: 10px; display: none;">
        <label for="print" >{l s='Enter Your Client Secret' mod='fenatoolkit'}</label>
        <input type="text"
               name="bank_id"
               id="bank_id"
               class="form-control"
               placeholder="8afa74ae-6ef9-48bb-93b2-9fe8be53db50"
               value="{$FENA_BANK_ID}"
               />
        </div>

    </div>


    <div class="panel-footer">
        <button type="submit" class="btn-default pull-right" name="fenaClient">
            <i class="process-icon-save"></i>
            {l s='Save' mod='fenatoolkit'}
        </button>

    </div>
        <div>
    <h3 style="padding-left: 20px"> Webhook & Redirect: </h3>
    <p>Webhook URL: https://{$Webhook}/module/fena/webhook</p>
    <p>Redirect URL: https://{$Webhook}/module/fena/Notification</p>




    </div>

</div>
</form>

<script>
  document.addEventListener("DOMContentLoaded", function () {
    // Your existing code here
    var validate = document.getElementById('fetchDataButton');
    var client_id = document.getElementById('clientId').value;
    var client_secret = document.getElementById('clientSecret').value;
    var selectBankDropdown = document.getElementById('selectBank');
    var selectedBankID = document.getElementById('bank_id');

    if (client_id && client_secret) {
        fetchDataAndUpdateDropdown(client_id, client_secret)
            .then(result => {
                if (result !== null) {
                    updateDropdownOptions(result);

                    var compare = selectedBankID.value;
                    if (compare) {
                        for (const option of selectBankDropdown.options) {
                            // Check if the option value matches the compare value
                            if (option.value === compare) {
                                // If there is a match, set the selected attribute
                                option.selected = true;
                            }
                        }
                    }
                }
            });
    }

    selectBankDropdown.addEventListener('change', function handleChange(event) {
        selected = event.target.value;
        selectedBankID.value = selected;
    });

    // Add an event listener for the button click
    fetchDataButton.addEventListener('click', function () {
        fetchDataAndUpdateDropdown(client_id, client_secret)
            .then(result => {
                if (result !== null) {
                    updateDropdownOptions(result);
                }
            });
    });
});

// Function to make the API call and update the dropdown
async function fetchDataAndUpdateDropdown(client_id, client_secret) {
    try {
        const response = await fetch('https://epos.api.fena.co/open/company/bank-accounts/list', {
            headers: {
                'secret-key': client_secret,
                'integration-id': client_id
            }
        });

        if (!response.ok) {
            throw new Error('Network response was not OK.');
        }

        const data = await response.json();
        console.log(data);

        const banks = {};
        data.data.docs.forEach(item => {
            if (item.status === "verified") {
                banks[item.name] = item.id;
            }
        });

        return banks;
    } catch (error) {
        console.error("Error fetching data:", error);
        return null; // or handle the error as needed
    }
}


function updateDropdownOptions(banks) {
    var selectBankDropdown = document.getElementById('selectBank');
    var selectedBankID = document.getElementById('bank_id');

    if (Object.keys(banks).length === 1) {
        const singleBankName = Object.keys(banks)[0];
        selectedBankID.value = banks[singleBankName];
    }

    // Clear existing options
    selectBankDropdown.innerHTML = '<option value=""></option>';

    // Add new options from the received data
    for (const [bankName, bankId] of Object.entries(banks)) {
        var optionElement = document.createElement('option');
        optionElement.value = bankId;
        optionElement.text = bankName;
        selectBankDropdown.appendChild(optionElement);
    }
}



</script>
