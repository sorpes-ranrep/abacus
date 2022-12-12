import styled from "styled-components";
import React from "react";

interface ModeSelectLabelProps {
    selected: boolean,
};

interface ModeSelectButtonProps {
    selected: boolean,
};

const ModeSelectLabel = styled.label<ModeSelectLabelProps>`
    font-family: var(--rlm-font);
    font-style: normal;
    font-weight: 500;
    font-size: 13px;
    line-height: 15px;
    text-align: center;

    color: ${props => props.selected ? props.theme.colors.text.blue : `${props.theme.colors.text.dark}99`};
`;

const ModeSelectButton = styled.button<ModeSelectButtonProps>`
    padding: 4px;
    gap: 10px;

    background: ${props => props.selected ? props.theme.colors.background.blue : props.theme.colors.background.evenLighter};
    border-radius: 4px;
    border: 0px;
`;

export interface ModeButtonProps {
    selected: boolean,
    text: string,
    onClick: React.MouseEventHandler<HTMLButtonElement>,
}

export function ModeButton(props: ModeButtonProps) {
    return (
        <ModeSelectButton selected={props.selected} onClick={props.onClick}>
            <ModeSelectLabel selected={props.selected}>{props.text}</ModeSelectLabel>
        </ModeSelectButton>
    );
}

export const ModeButtonsDiv = styled.div`
    padding: 4px;
    margin: 4px auto;

    width: max-content;
    display: block;

    background: ${props => props.theme.colors.background.evenLighter};
    border-radius: 6px;
`;