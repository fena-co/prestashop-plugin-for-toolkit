<?php
/**
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
 *  @author   "Fena <support@fena.co>"
 *  @copyright Since 2023 Fena Labs Ltd
 *  @license   http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 */
if (!defined('_PS_VERSION_')) {
    exit;
}

use PrestaShop\PrestaShop\Core\Payment\PaymentOption;

class Fenatoolkit extends PaymentModule
{
    public function __construct()
    {
        $this->name = 'fenatoolkit';
        $this->module_key = 'ea2306e500262e5bc4b35e4bb0be873a';
        $this->author = 'Fena';
        $this->version = '1.0.0';
        $this->bootstrap = true;
        $this->tab = 'payments_gateways';
        $this->displayName = $this->l('Fena Payments for Business Toolkit');
        $this->description = $this->l('The fastest way to pay via Open Banking');
        $this->ps_versions_compliancy = ['min' => '1.7.0.0', 'max' => '1.7.8.99'];
        parent::__construct();
    }

    public function install()
    {
        return parent::install()
            && $this->registerHook('Header')
            && $this->registerHook('displayPaymentReturn')
            && $this->registerHook('paymentOptions');
    }

    public function uninstall()
    {
        return parent::uninstall();
    }

    public function hookDisplayPaymentReturn()
    {
        $this->context->smarty->assign([]);

        return $this->display(__FILE__, 'views/templates/hook/return.tpl');
    }

    public function hookPaymentOptions()
    {
        $fena = new PaymentOption();
        $fena->setModuleName($this->name)
            ->setCallToActionText('Pay by Bank')
            ->setAdditionalInformation('Pay instantly via online bank transfer – Supports most UK banks')
            ->setLogo(Media::getMediaPath(_PS_MODULE_DIR_ . $this->name . '/views/img/payment.svg'))
            ->setAction($this->context->link->getModuleLink($this->name, 'payment'));

        return [$fena];
    }

    public function hookHeader()
    {
        $this->context->controller->addCSS([
            $this->_path . 'views/css/fenatoolkit.css',
        ]);
        $this->context->controller->addJS([
            $this->_path . 'views/js/fenatoolkit.js',
        ]);
    }

    public function getContent()
    {
        $output = '';
        $url = $_SERVER['HTTP_HOST'];
        $this->context->smarty->assign([
            'Webhook' => $url,
        ]);
        if (Tools::isSubmit('fenaClient')) {
            $clientId = Tools::getValue('clientId');
            $clientSecret = Tools::getValue('clientSecret');
            $bankId = Tools::getValue('bank_id');
            Configuration::updateValue('FENA_CLIENTID', $clientId);
            Configuration::updateValue('FENA_CLIENTSECRET', $clientSecret);
            Configuration::updateValue('FENA_BANK_ID', $bankId);
            $output = $this->displayConfirmation($this->l('Settings updated'));
        }
        $this->context->smarty->assign([
            'FENA_CLIENTID' => Configuration::get('FENA_CLIENTID'),
        ]);
        $this->context->smarty->assign([
            'FENA_CLIENTSECRET' => Configuration::get('FENA_CLIENTSECRET'),
        ]);
        $this->context->smarty->assign([
            'FENA_BANK_ID' => Configuration::get('FENA_BANK_ID'),
        ]);


        return $output . $this->display(__FILE__, 'views/templates/admin/configuration.tpl');
    }
}
